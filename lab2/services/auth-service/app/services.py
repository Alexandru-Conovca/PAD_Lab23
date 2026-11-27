from datetime import datetime, timedelta, timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from .config import settings
from .models import Account, RefreshToken
from .schemas import AuthResponse, LoginRequest, RegisterRequest, TokenResponse, UserResponse
from .security import create_access_token, generate_refresh_token, hash_password, verify_password


class AuthService:
    @staticmethod
    def register(db: Session, req: RegisterRequest) -> AuthResponse:
        existing = db.query(Account).filter(Account.email == req.email.lower()).first()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="User with this email already exists",
            )
        hashed = hash_password(req.password)
        account = Account(
            email=req.email.lower(),
            password_hash=hashed,
            full_name=req.name,
            role="user",
        )
        db.add(account)
        db.commit()
        db.refresh(account)

        access_token, expires_in = create_access_token(account.id, account.email, account.role)
        raw_refresh = generate_refresh_token()
        refresh_expires = datetime.now(timezone.utc) + timedelta(days=settings.refresh_token_expire_days)

        token_record = RefreshToken(
            user_id=account.id,
            token=raw_refresh,
            expires_at=refresh_expires,
        )
        db.add(token_record)
        db.commit()

        return AuthResponse(
            token=TokenResponse(
                access_token=access_token,
                refresh_token=raw_refresh,
                expires_in=expires_in,
            ),
            user=UserResponse(
                id=account.id,
                email=account.email,
                name=account.full_name,
                role=account.role,
                created_at=account.created_at,
            ),
        )

    @staticmethod
    def login(db: Session, req: LoginRequest) -> AuthResponse:
        account = db.query(Account).filter(Account.email == req.email.lower()).first()
        if not account or not verify_password(req.password, account.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
            )

        access_token, expires_in = create_access_token(account.id, account.email, account.role)
        raw_refresh = generate_refresh_token()
        refresh_expires = datetime.now(timezone.utc) + timedelta(days=settings.refresh_token_expire_days)

        token_record = RefreshToken(
            user_id=account.id,
            token=raw_refresh,
            expires_at=refresh_expires,
        )
        db.add(token_record)
        db.commit()

        return AuthResponse(
            token=TokenResponse(
                access_token=access_token,
                refresh_token=raw_refresh,
                expires_in=expires_in,
            ),
            user=UserResponse(
                id=account.id,
                email=account.email,
                name=account.full_name,
                role=account.role,
                created_at=account.created_at,
            ),
        )

    @staticmethod
    def refresh(db: Session, refresh_token: str) -> TokenResponse:
        token_record = db.query(RefreshToken).filter(
            RefreshToken.token == refresh_token,
            RefreshToken.revoked == False,
        ).first()

        now = datetime.now(timezone.utc)
        if not token_record or token_record.expires_at < now:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired refresh token",
            )

        account = db.query(Account).filter(Account.id == token_record.user_id).first()
        if not account:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found",
            )

        # Rotate refresh token
        token_record.revoked = True
        new_refresh = generate_refresh_token()
        new_expires = now + timedelta(days=settings.refresh_token_expire_days)
        new_record = RefreshToken(
            user_id=account.id,
            token=new_refresh,
            expires_at=new_expires,
        )
        db.add(new_record)
        db.commit()

        access_token, expires_in = create_access_token(account.id, account.email, account.role)
        return TokenResponse(
            access_token=access_token,
            refresh_token=new_refresh,
            expires_in=expires_in,
        )
