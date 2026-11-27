from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from .database import get_db
from .models import Account
from .schemas import AuthResponse, LoginRequest, RefreshTokenRequest, RegisterRequest, TokenResponse, UserResponse
from .security import get_current_user
from .services import AuthService

router = APIRouter(prefix="/api/auth", tags=["Authentication"])


@router.post("/register", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    """Register a new user account and receive authentication tokens."""
    return AuthService.register(db, req)


@router.post("/login", response_model=AuthResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    """Log in with existing credentials and receive authentication tokens."""
    return AuthService.login(db, req)


@router.post("/refresh", response_model=TokenResponse)
def refresh(req: RefreshTokenRequest, db: Session = Depends(get_db)):
    """Refresh an access token using a valid refresh token."""
    return AuthService.refresh(db, req.refresh_token)


@router.get("/me", response_model=UserResponse)
def me(current_user: Account = Depends(get_current_user)):
    """Get the profile of the currently authenticated user."""
    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        name=current_user.full_name,
        role=current_user.role,
        created_at=current_user.created_at,
    )
