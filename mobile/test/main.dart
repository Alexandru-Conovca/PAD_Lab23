// E1. Переменные и null safety
int parseOrDefault(String? input, int fallback) {
  if (input == null) return fallback;
  return int.tryParse(input) ?? fallback;
}

// E2. Коллекции и функциональные методы
double promotedAverage(List<int> grades) {
  final passingGrades = grades.where((grade) => grade >= 5);
  if (passingGrades.isEmpty) return 0.0;
  
  final sum = passingGrades.reduce((acc, grade) => acc + grade);
  return sum / passingGrades.length;
}

// E3. Функции с именованными и необязательными параметрами
String formatPrice(double amount, {String currency = 'MDL', int decimals = 2}) {
  return '${amount.toStringAsFixed(decimals)} $currency';
}

// E4. Классы
class Student {
  final String name;
  final String group;

  // Основной конструктор
  Student(this.name, this.group);

  // Именованный конструктор
  Student.guest()
      : name = 'Guest',
        group = '—';

  @override
  String toString() => 'Student($name, $group)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          group == other.group;

  @override
  int get hashCode => Object.hash(name, group);
}

// E5. Mixin
mixin Loggable {
  void log(String msg) {
    print('[$runtimeType] $msg');
  }
}

class CartService with Loggable {
  void addItem(String item) {
    log('товар добавлен: $item');
  }
}

class AuthService with Loggable {
  void login(String username) {
    log('пользователь вошёл: $username');
  }
}

// E6. Асинхронное программирование
Future<String> fetchProfile(String username) async {
  await Future.delayed(const Duration(seconds: 2));
  return 'Профиль: $username, группа TI-236, решено упражнений: 42';
}

void main() async {
  print('--- E1. Переменные и null safety ---');
  print(parseOrDefault('42', 0)); // 42
  print(parseOrDefault('abc', 0)); // 0
  print(parseOrDefault(null, 7)); // 7
  print(parseOrDefault('7.5', -1)); // -1

  print('\n--- E2. Коллекции и функциональные методы ---');
  print(promotedAverage([9, 4, 7, 10, 3, 5])); // 7.75
  print(promotedAverage([10, 10, 9])); // 9.666666666666666
  print(promotedAverage([3, 4, 2])); // 0.0

  print('\n--- E3. Именованные параметры ---');
  print(formatPrice(12.5)); // "12.50 MDL"
  print(formatPrice(12.5, currency: 'MDL')); // "12.50 MDL"
  print(formatPrice(99.999, currency: 'EUR')); // "100.00 EUR"
  print(formatPrice(7.5, currency: 'USD', decimals: 1)); // "7.5 USD"

  print('\n--- E4. Классы ---');
  print(Student('Conovca Alexandru', 'TI-236')); // Student(Conovca Alexandru, TI-236)
  print(Student.guest()); // Student(Guest, —)
  print(Student('Conovca Alexandru', 'TI-236') == Student('Conovca Alexandru', 'TI-236')); // true
  print({Student('Conovca Alexandru', 'TI-236'), Student('Conovca Alexandru', 'TI-236')}.length); // 1

  print('\n--- E5. Mixin ---');
  CartService().addItem('Paracetamol');
  AuthService().login('alexandru.conovca');

  print('\n--- E6. Асинхронное программирование ---');
  print('Загружается профиль пользователя conovca.alexandru...');
  final profile = await fetchProfile('alexandru.conovca');
  print(profile);
  print('Готово.');
}