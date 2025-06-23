# AlphaWave Stock Trading App - System Architecture Documentation (University Project)

## 1. System Architecture Overview

### High-Level System Description
AlphaWave is a stock trading mobile application simulator built with Flutter for educational purposes. The app demonstrates core concepts of mobile app development including state management, UI design, and object-oriented programming. All data is stored in-memory within the application classes, making it a self-contained learning project.

### Main Components and Their Purpose
1. **User Management**: Simple login system with in-memory user storage
2. **Dashboard**: Central hub displaying portfolio overview
3. **Portfolio Management**: Tracks simulated stock holdings and transactions
4. **Watchlist**: Allows users to save and monitor favorite stocks
5. **Payment Simulation**: Mock payment processing for learning purposes
6. **Stock Data**: Pre-populated stock data stored in-memory

### Overall Data Flow
- All data is stored in static lists within service classes
- No external API calls or database connections
- State persists only during app runtime
- Mock data is initialized on app startup

## 2. Class Documentation

### Core Models

#### User
**Purpose**: Represents a user account with basic information
```dart
class User {
  // Properties
  String userID;
  String name;
  String email;
  String username;
  String password; // Plain text for simplicity
  String phoneNumber;
  DateTime createdAt;
  DateTime lastLogin;
  
  // Constructor
  User({
    required this.userID,
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    required this.phoneNumber,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastLogin = lastLogin ?? DateTime.now();
  
  // Methods
  void updateProfile(String name, String email, String phoneNumber) {
    this.name = name;
    this.email = email;
    this.phoneNumber = phoneNumber;
  }
  
  void updateLastLogin() {
    lastLogin = DateTime.now();
  }
}
```

#### Stock
**Purpose**: Represents stock information with mock data
```dart
class Stock {
  // Properties
  String stockID;
  String symbol;
  String company;
  String exchange;
  double currentPrice;
  double previousClose;
  double openPrice;
  double dayHigh;
  double dayLow;
  double volume;
  double marketCap;
  DateTime lastUpdate;
  
  // Constructor
  Stock({
    required this.stockID,
    required this.symbol,
    required this.company,
    required this.exchange,
    required this.currentPrice,
    required this.previousClose,
    required this.openPrice,
    required this.dayHigh,
    required this.dayLow,
    required this.volume,
    required this.marketCap,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();
  
  // Methods
  double calculateChange() {
    return currentPrice - previousClose;
  }
  
  double calculateChangePercent() {
    return ((currentPrice - previousClose) / previousClose) * 100;
  }
  
  void simulatePriceChange() {
    // Simulate random price movement for demo
    Random random = Random();
    double change = (random.nextDouble() - 0.5) * 2; // -1% to +1%
    currentPrice = currentPrice * (1 + change / 100);
    lastUpdate = DateTime.now();
  }
}
```

#### Portfolio
**Purpose**: Container for user's holdings
```dart
class Portfolio {
  // Properties
  String portfolioID;
  String userID;
  String name;
  List<StockHolding> holdings;
  DateTime createdAt;
  DateTime lastUpdated;
  
  // Constructor
  Portfolio({
    required this.portfolioID,
    required this.userID,
    required this.name,
    List<StockHolding>? holdings,
    DateTime? createdAt,
  }) : holdings = holdings ?? [],
       createdAt = createdAt ?? DateTime.now(),
       lastUpdated = DateTime.now();
  
  // Calculated Properties
  double get totalValue {
    return holdings.fold(0, (sum, holding) => sum + holding.currentValue);
  }
  
  double get totalCost {
    return holdings.fold(0, (sum, holding) => sum + holding.totalCost);
  }
  
  double get totalGainLoss {
    return totalValue - totalCost;
  }
  
  double get totalGainLossPercent {
    return totalCost > 0 ? (totalGainLoss / totalCost) * 100 : 0;
  }
  
  // Methods
  void addHolding(StockHolding holding) {
    holdings.add(holding);
    lastUpdated = DateTime.now();
  }
  
  void removeHolding(String holdingID) {
    holdings.removeWhere((h) => h.holdingID == holdingID);
    lastUpdated = DateTime.now();
  }
  
  StockHolding? getHolding(String stockID) {
    try {
      return holdings.firstWhere((h) => h.stockID == stockID);
    } catch (e) {
      return null;
    }
  }
}
```

#### StockHolding
**Purpose**: Represents user's position in a stock
```dart
class StockHolding {
  // Properties
  String holdingID;
  String portfolioID;
  String stockID;
  double quantity;
  double averagePurchasePrice;
  DateTime firstPurchaseDate;
  Stock? stock; // Reference to stock object
  
  // Constructor
  StockHolding({
    required this.holdingID,
    required this.portfolioID,
    required this.stockID,
    required this.quantity,
    required this.averagePurchasePrice,
    DateTime? firstPurchaseDate,
    this.stock,
  }) : firstPurchaseDate = firstPurchaseDate ?? DateTime.now();
  
  // Calculated Properties
  double get totalCost {
    return quantity * averagePurchasePrice;
  }
  
  double get currentValue {
    return stock != null ? quantity * stock!.currentPrice : 0;
  }
  
  double get unrealizedGainLoss {
    return currentValue - totalCost;
  }
  
  double get unrealizedGainLossPercent {
    return totalCost > 0 ? (unrealizedGainLoss / totalCost) * 100 : 0;
  }
  
  // Methods
  void addShares(double newQuantity, double purchasePrice) {
    double totalPreviousCost = totalCost;
    double newCost = newQuantity * purchasePrice;
    quantity += newQuantity;
    averagePurchasePrice = (totalPreviousCost + newCost) / quantity;
  }
  
  void removeShares(double sellQuantity) {
    if (sellQuantity <= quantity) {
      quantity -= sellQuantity;
    }
  }
}
```

#### Transaction
**Purpose**: Records buy/sell activities
```dart
class Transaction {
  // Properties
  String transactionID;
  String userID;
  String portfolioID;
  String stockID;
  TransactionType type;
  double quantity;
  double price;
  double commission;
  DateTime transactionDate;
  TransactionStatus status;
  
  // Constructor
  Transaction({
    required this.transactionID,
    required this.userID,
    required this.portfolioID,
    required this.stockID,
    required this.type,
    required this.quantity,
    required this.price,
    this.commission = 0.0,
    DateTime? transactionDate,
    this.status = TransactionStatus.completed,
  }) : transactionDate = transactionDate ?? DateTime.now();
  
  // Calculated Properties
  double get totalAmount {
    return (quantity * price) + commission;
  }
  
  // Methods
  Map<String, dynamic> toMap() {
    return {
      'transactionID': transactionID,
      'type': type.toString(),
      'quantity': quantity,
      'price': price,
      'totalAmount': totalAmount,
      'date': transactionDate,
    };
  }
}

// Enums
enum TransactionType { buy, sell }
enum TransactionStatus { pending, completed, failed }
```

#### Watchlist
**Purpose**: User's favorite stocks list
```dart
class Watchlist {
  // Properties
  String watchlistID;
  String userID;
  String name;
  List<WatchlistItem> items;
  DateTime createdDate;
  DateTime lastModified;
  
  // Constructor
  Watchlist({
    required this.watchlistID,
    required this.userID,
    this.name = "My Watchlist",
    List<WatchlistItem>? items,
    DateTime? createdDate,
  }) : items = items ?? [],
       createdDate = createdDate ?? DateTime.now(),
       lastModified = DateTime.now();
  
  // Methods
  void addStock(String stockID, Stock stock) {
    final newItem = WatchlistItem(
      itemID: DateTime.now().millisecondsSinceEpoch.toString(),
      watchlistID: watchlistID,
      stockID: stockID,
      position: items.length,
      stock: stock,
    );
    items.add(newItem);
    lastModified = DateTime.now();
  }
  
  void removeStock(String stockID) {
    items.removeWhere((item) => item.stockID == stockID);
    _reorderItems();
    lastModified = DateTime.now();
  }
  
  void _reorderItems() {
    for (int i = 0; i < items.length; i++) {
      items[i].position = i;
    }
  }
  
  bool containsStock(String stockID) {
    return items.any((item) => item.stockID == stockID);
  }
}
```

#### WatchlistItem
**Purpose**: Individual entry in watchlist
```dart
class WatchlistItem {
  // Properties
  String itemID;
  String watchlistID;
  String stockID;
  int position;
  DateTime addedDate;
  double? priceAlert;
  Stock? stock; // Reference to stock object
  
  // Constructor
  WatchlistItem({
    required this.itemID,
    required this.watchlistID,
    required this.stockID,
    required this.position,
    DateTime? addedDate,
    this.priceAlert,
    this.stock,
  }) : addedDate = addedDate ?? DateTime.now();
  
  // Methods
  void setPriceAlert(double alertPrice) {
    priceAlert = alertPrice;
  }
  
  bool checkPriceAlert() {
    if (priceAlert != null && stock != null) {
      return stock!.currentPrice >= priceAlert!;
    }
    return false;
  }
}
```

#### Payment
**Purpose**: Simple payment record for transactions
```dart
class Payment {
  // Properties
  String paymentID;
  String userID;
  String? transactionID;
  PaymentMethod paymentMethod;
  double amount;
  String currency;
  PaymentStatus status;
  DateTime paymentDate;
  
  // Constructor
  Payment({
    required this.paymentID,
    required this.userID,
    this.transactionID,
    required this.paymentMethod,
    required this.amount,
    this.currency = "USD",
    this.status = PaymentStatus.completed,
    DateTime? paymentDate,
  }) : paymentDate = paymentDate ?? DateTime.now();
  
  // Methods
  Map<String, dynamic> toMap() {
    return {
      'paymentID': paymentID,
      'amount': amount,
      'method': paymentMethod.toString(),
      'status': status.toString(),
      'date': paymentDate,
    };
  }
}

// Enums
enum PaymentMethod { card, bank, wallet }
enum PaymentStatus { pending, completed, failed }
```

### Service Classes (In-Memory Data Management)

#### UserService
**Purpose**: Manages users with in-memory storage
```dart
class UserService {
  // Static in-memory storage
  static final List<User> _users = [
    User(
      userID: "1",
      name: "John Doe",
      email: "john@example.com",
      username: "johndoe",
      password: "password123",
      phoneNumber: "1234567890",
    ),
    User(
      userID: "2",
      name: "Jane Smith",
      email: "jane@example.com",
      username: "janesmith",
      password: "password456",
      phoneNumber: "0987654321",
    ),
  ];
  
  static User? _currentUser;
  
  // Methods
  static Future<User?> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    
    try {
      final user = _users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      user.updateLastLogin();
      _currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }
  
  static Future<User> register(User newUser) async {
    await Future.delayed(Duration(seconds: 1));
    _users.add(newUser);
    _currentUser = newUser;
    return newUser;
  }
  
  static void logout() {
    _currentUser = null;
  }
  
  static User? getCurrentUser() {
    return _currentUser;
  }
  
  static Future<void> updateProfile(User updatedUser) async {
    await Future.delayed(Duration(milliseconds: 500));
    final index = _users.indexWhere((u) => u.userID == updatedUser.userID);
    if (index != -1) {
      _users[index] = updatedUser;
      if (_currentUser?.userID == updatedUser.userID) {
        _currentUser = updatedUser;
      }
    }
  }
}
```

#### StockDataService
**Purpose**: Provides mock stock data
```dart
class StockDataService {
  // Static mock stock data
  static final List<Stock> _stocks = [
    Stock(
      stockID: "1",
      symbol: "AAPL",
      company: "Apple Inc.",
      exchange: "NASDAQ",
      currentPrice: 150.25,
      previousClose: 148.50,
      openPrice: 149.00,
      dayHigh: 151.00,
      dayLow: 148.25,
      volume: 75000000,
      marketCap: 2500000000000,
    ),
    Stock(
      stockID: "2",
      symbol: "GOOGL",
      company: "Alphabet Inc.",
      exchange: "NASDAQ",
      currentPrice: 2750.80,
      previousClose: 2725.50,
      openPrice: 2730.00,
      dayHigh: 2760.00,
      dayLow: 2720.00,
      volume: 1200000,
      marketCap: 1800000000000,
    ),
    Stock(
      stockID: "3",
      symbol: "MSFT",
      company: "Microsoft Corporation",
      exchange: "NASDAQ",
      currentPrice: 305.50,
      previousClose: 302.00,
      openPrice: 303.00,
      dayHigh: 307.00,
      dayLow: 301.50,
      volume: 22000000,
      marketCap: 2300000000000,
    ),
    Stock(
      stockID: "4",
      symbol: "AMZN",
      company: "Amazon.com Inc.",
      exchange: "NASDAQ",
      currentPrice: 3320.00,
      previousClose: 3300.00,
      openPrice: 3305.00,
      dayHigh: 3335.00,
      dayLow: 3295.00,
      volume: 3500000,
      marketCap: 1700000000000,
    ),
    Stock(
      stockID: "5",
      symbol: "TSLA",
      company: "Tesla Inc.",
      exchange: "NASDAQ",
      currentPrice: 875.50,
      previousClose: 860.00,
      openPrice: 865.00,
      dayHigh: 885.00,
      dayLow: 855.00,
      volume: 18000000,
      marketCap: 900000000000,
    ),
  ];
  
  // Methods
  static Future<Stock?> getStockBySymbol(String symbol) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return _stocks.firstWhere((s) => s.symbol == symbol);
    } catch (e) {
      return null;
    }
  }
  
  static Future<Stock?> getStockByID(String stockID) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return _stocks.firstWhere((s) => s.stockID == stockID);
    } catch (e) {
      return null;
    }
  }
  
  static Future<List<Stock>> getAllStocks() async {
    await Future.delayed(Duration(milliseconds: 500));
    return List.from(_stocks);
  }
  
  static Future<List<Stock>> searchStocks(String query) async {
    await Future.delayed(Duration(milliseconds: 300));
    final lowercaseQuery = query.toLowerCase();
    return _stocks.where((stock) =>
      stock.symbol.toLowerCase().contains(lowercaseQuery) ||
      stock.company.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
  
  static void simulatePriceChanges() {
    // Simulate random price movements
    for (var stock in _stocks) {
      stock.simulatePriceChange();
    }
  }
}
```

#### PortfolioManagerService
**Purpose**: Manages user portfolios in memory
```dart
class PortfolioManagerService {
  // Static storage
  static final Map<String, Portfolio> _portfolios = {};
  
  // Initialize with demo data
  static void initializeDemoData() {
    // Create demo portfolio for user 1
    final portfolio1 = Portfolio(
      portfolioID: "p1",
      userID: "1",
      name: "Main Portfolio",
    );
    
    // Add some holdings
    portfolio1.addHolding(StockHolding(
      holdingID: "h1",
      portfolioID: "p1",
      stockID: "1",
      quantity: 100,
      averagePurchasePrice: 145.00,
      stock: StockDataService._stocks[0],
    ));
    
    portfolio1.addHolding(StockHolding(
      holdingID: "h2",
      portfolioID: "p1",
      stockID: "3",
      quantity: 50,
      averagePurchasePrice: 290.00,
      stock: StockDataService._stocks[2],
    ));
    
    _portfolios["1"] = portfolio1;
  }
  
  // Methods
  static Future<Portfolio?> getUserPortfolio(String userID) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _portfolios[userID];
  }
  
  static Future<Portfolio> createPortfolio(String userID, String name) async {
    await Future.delayed(Duration(milliseconds: 300));
    final portfolio = Portfolio(
      portfolioID: DateTime.now().millisecondsSinceEpoch.toString(),
      userID: userID,
      name: name,
    );
    _portfolios[userID] = portfolio;
    return portfolio;
  }
  
  static Future<void> addHolding(String userID, StockHolding holding) async {
    await Future.delayed(Duration(milliseconds: 300));
    final portfolio = _portfolios[userID];
    if (portfolio != null) {
      // Check if already holding this stock
      final existingHolding = portfolio.getHolding(holding.stockID);
      if (existingHolding != null) {
        existingHolding.addShares(holding.quantity, holding.averagePurchasePrice);
      } else {
        portfolio.addHolding(holding);
      }
    }
  }
  
  static Future<void> removeHolding(String userID, String holdingID) async {
    await Future.delayed(Duration(milliseconds: 300));
    final portfolio = _portfolios[userID];
    portfolio?.removeHolding(holdingID);
  }
  
  static void updateStockReferences() {
    // Update stock references in all holdings
    for (var portfolio in _portfolios.values) {
      for (var holding in portfolio.holdings) {
        holding.stock = StockDataService._stocks.firstWhere(
          (s) => s.stockID == holding.stockID,
        );
      }
    }
  }
}
```

#### TransactionService
**Purpose**: Records and manages transactions
```dart
class TransactionService {
  // Static storage
  static final List<Transaction> _transactions = [];
  
  // Methods
  static Future<Transaction> createBuyTransaction({
    required String userID,
    required String portfolioID,
    required String stockID,
    required double quantity,
    required double price,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    final transaction = Transaction(
      transactionID: DateTime.now().millisecondsSinceEpoch.toString(),
      userID: userID,
      portfolioID: portfolioID,
      stockID: stockID,
      type: TransactionType.buy,
      quantity: quantity,
      price: price,
      commission: 4.95, // Fixed commission
    );
    
    _transactions.add(transaction);
    
    // Update portfolio
    final stock = await StockDataService.getStockByID(stockID);
    if (stock != null) {
      final holding = StockHolding(
        holdingID: DateTime.now().millisecondsSinceEpoch.toString(),
        portfolioID: portfolioID,
        stockID: stockID,
        quantity: quantity,
        averagePurchasePrice: price,
        stock: stock,
      );
      await PortfolioManagerService.addHolding(userID, holding);
    }
    
    return transaction;
  }
  
  static Future<Transaction> createSellTransaction({
    required String userID,
    required String portfolioID,
    required String stockID,
    required double quantity,
    required double price,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    final transaction = Transaction(
      transactionID: DateTime.now().millisecondsSinceEpoch.toString(),
      userID: userID,
      portfolioID: portfolioID,
      stockID: stockID,
      type: TransactionType.sell,
      quantity: quantity,
      price: price,
      commission: 4.95,
    );
    
    _transactions.add(transaction);
    
    // Update portfolio
    final portfolio = await PortfolioManagerService.getUserPortfolio(userID);
    if (portfolio != null) {
      final holding = portfolio.getHolding(stockID);
      if (holding != null) {
        holding.removeShares(quantity);
        if (holding.quantity <= 0) {
          await PortfolioManagerService.removeHolding(userID, holding.holdingID);
        }
      }
    }
    
    return transaction;
  }
  
  static Future<List<Transaction>> getUserTransactions(String userID) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _transactions.where((t) => t.userID == userID).toList()
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }
}
```

#### WatchlistService
**Purpose**: Manages user watchlists
```dart
class WatchlistService {
  // Static storage
  static final Map<String, Watchlist> _watchlists = {};
  
  // Initialize demo data
  static void initializeDemoData() {
    final watchlist1 = Watchlist(
      watchlistID: "w1",
      userID: "1",
      name: "Tech Stocks",
    );
    
    // Add some stocks to watchlist
    watchlist1.addStock("2", StockDataService._stocks[1]); // GOOGL
    watchlist1.addStock("5", StockDataService._stocks[4]); // TSLA
    
    _watchlists["1"] = watchlist1;
  }
  
  // Methods
  static Future<Watchlist?> getUserWatchlist(String userID) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _watchlists[userID];
  }
  
  static Future<Watchlist> createWatchlist(String userID, String name) async {
    await Future.delayed(Duration(milliseconds: 300));
    final watchlist = Watchlist(
      watchlistID: DateTime.now().millisecondsSinceEpoch.toString(),
      userID: userID,
      name: name,
    );
    _watchlists[userID] = watchlist;
    return watchlist;
  }
  
  static Future<void> addToWatchlist(String userID, String stockID) async {
    await Future.delayed(Duration(milliseconds: 300));
    final watchlist = _watchlists[userID];
    final stock = await StockDataService.getStockByID(stockID);
    
    if (watchlist != null && stock != null) {
      watchlist.addStock(stockID, stock);
    }
  }
  
  static Future<void> removeFromWatchlist(String userID, String stockID) async {
    await Future.delayed(Duration(milliseconds: 300));
    final watchlist = _watchlists[userID];
    watchlist?.removeStock(stockID);
  }
}
```

#### PaymentService
**Purpose**: Simulates payment processing
```dart
class PaymentService {
  // Static storage
  static final List<Payment> _payments = [];
  
  // Methods
  static Future<Payment> processPayment({
    required String userID,
    required double amount,
    required PaymentMethod method,
    String? transactionID,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    
    final payment = Payment(
      paymentID: DateTime.now().millisecondsSinceEpoch.toString(),
      userID: userID,
      transactionID: transactionID,
      paymentMethod: method,
      amount: amount,
    );
    
    _payments.add(payment);
    return payment;
  }
  
  static Future<List<Payment>> getUserPayments(String userID) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _payments.where((p) => p.userID == userID).toList()
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
  }
}
```

## 3. Screen Classes

### Authentication Screens

#### LoginScreen
```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// Features:
// - Username/password input fields
// - Login button
// - "Create Account" navigation
// - Simple validation
// - Loading indicator during login
```

#### RegisterScreen
```dart
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

// Features:
// - User registration form
// - All user fields (name, email, username, password, phone)
// - Form validation
// - Create account button
// - Back to login navigation
```

### Main App Screens

#### DashboardScreen
```dart
class DashboardScreen extends StatelessWidget {
  final User user;
  
  DashboardScreen({required this.user});
  
  // Features:
  // - Portfolio value summary card
  // - Quick stats (total gain/loss)
  // - Recent transactions list
  // - Market overview (top stocks)
  // - Navigation to other screens
}
```

#### PortfolioScreen
```dart
class PortfolioScreen extends StatelessWidget {
  final Portfolio portfolio;
  
  PortfolioScreen({required this.portfolio});
  
  // Features:
  // - Holdings list with current values
  // - Portfolio performance chart
  // - Total portfolio metrics
  // - Individual holding cards
  // - Sell functionality
}
```

#### StockDetailsScreen
```dart
class StockDetailsScreen extends StatelessWidget {
  final Stock stock;
  final User user;
  
  StockDetailsScreen({required this.stock, required this.user});
  
  // Features:
  // - Stock price and change
  // - Company information
  // - Price statistics (high/low/volume)
  // - Buy button
  // - Add to watchlist button
  // - Simple price chart visualization
}
```

#### WatchlistScreen
```dart
class WatchlistScreen extends StatelessWidget {
  final Watchlist watchlist;
  
  WatchlistScreen({required this.watchlist});
  
  // Features:
  // - Watchlist items grid/list
  // - Stock price and change for each
  // - Remove from watchlist
  // - Navigate to stock details
  // - Empty state when no items
}
```

#### TransactionHistoryScreen
```dart
class TransactionHistoryScreen extends StatelessWidget {
  final List<Transaction> transactions;
  
  TransactionHistoryScreen({required this.transactions});
  
  // Features:
  // - Transaction list (buy/sell)
  // - Transaction details (date, quantity, price)
  // - Color coding (green for buy, red for sell)
  // - Total amount for each transaction
  // - Sort by date
}
```

## 4. Implementation Guidelines

### App Initialization
```dart
void main() {
  // Initialize demo data
  StockDataService.initializeDemoData();
  PortfolioManagerService.initializeDemoData();
  WatchlistService.initializeDemoData();
  
  runApp(AlphaWaveApp());
}
```

### State Management (Simple Provider Pattern)
```dart
class AppState extends ChangeNotifier {
  User? _currentUser;
  Portfolio? _portfolio;
  Watchlist? _watchlist;
  List<Stock> _stocks = [];
  
  User? get currentUser => _currentUser;
  Portfolio? get portfolio => _portfolio;
  Watchlist? get watchlist => _watchlist;
  List<Stock> get stocks => _stocks;
  
  Future<void> login(String username, String password) async {
    final user = await UserService.login(username, password);
    if (user != null) {
      _currentUser = user;
      await loadUserData();
      notifyListeners();
    }
  }
  
  Future<void> loadUserData() async {
    if (_currentUser != null) {
      _portfolio = await PortfolioManagerService.getUserPortfolio(_currentUser!.userID);
      _watchlist = await WatchlistService.getUserWatchlist(_currentUser!.userID);
      _stocks = await StockDataService.getAllStocks();
      
      // Update stock references
      PortfolioManagerService.updateStockReferences();
    }
  }
  
  void logout() {
    UserService.logout();
    _currentUser = null;
    _portfolio = null;
    _watchlist = null;
    notifyListeners();
  }
  
  // Additional methods for buying, selling, watchlist management, etc.
}
```

### Navigation Structure
```
MaterialApp
├── LoginScreen (initial route)
│   └── RegisterScreen
└── HomeScreen (after login)
    ├── DashboardScreen (index 0)
    ├── PortfolioScreen (index 1)
    ├── MarketScreen (index 2)
    │   └── StockDetailsScreen
    ├── WatchlistScreen (index 3)
    └── ProfileScreen (index 4)
        └── TransactionHistoryScreen
```

### Sample Implementation Code

#### Main App Structure
```dart
class AlphaWaveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'AlphaWave Trading',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
```

#### Home Screen with Bottom Navigation
```dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    final List<Widget> _screens = [
      DashboardScreen(user: appState.currentUser!),
      PortfolioScreen(portfolio: appState.portfolio!),
      MarketScreen(stocks: appState.stocks),
      WatchlistScreen(watchlist: appState.watchlist!),
      ProfileScreen(user: appState.currentUser!),
    ];
    
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Portfolio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Watchlist'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

### UI Components Examples

#### Stock Card Widget
```dart
class StockCard extends StatelessWidget {
  final Stock stock;
  final VoidCallback? onTap;
  
  StockCard({required this.stock, this.onTap});
  
  @override
  Widget build(BuildContext context) {
    final changePercent = stock.calculateChangePercent();
    final isPositive = changePercent >= 0;
    
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(stock.symbol, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(stock.company),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\${stock.currentPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Portfolio Summary Widget
```dart
class PortfolioSummaryCard extends StatelessWidget {
  final Portfolio portfolio;
  
  PortfolioSummaryCard({required this.portfolio});
  
  @override
  Widget build(BuildContext context) {
    final isPositive = portfolio.totalGainLoss >= 0;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Portfolio Value', style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 8),
            Text(
              '\${portfolio.totalValue.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Gain/Loss', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${isPositive ? '+' : ''}\${portfolio.totalGainLoss.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Percentage', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${isPositive ? '+' : ''}${portfolio.totalGainLossPercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### Buy/Sell Implementation Example

#### Buy Stock Dialog
```dart
class BuyStockDialog extends StatefulWidget {
  final Stock stock;
  final User user;
  
  BuyStockDialog({required this.stock, required this.user});
  
  @override
  _BuyStockDialogState createState() => _BuyStockDialogState();
}

class _BuyStockDialogState extends State<BuyStockDialog> {
  final _quantityController = TextEditingController();
  double _totalCost = 0;
  
  void _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _totalCost = quantity * widget.stock.currentPrice + 4.95; // Including commission
    });
  }
  
  Future<void> _executeBuy() async {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) return;
    
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Create transaction
    await TransactionService.createBuyTransaction(
      userID: widget.user.userID,
      portfolioID: appState.portfolio!.portfolioID,
      stockID: widget.stock.stockID,
      quantity: quantity,
      price: widget.stock.currentPrice,
    );
    
    // Create payment record
    await PaymentService.processPayment(
      userID: widget.user.userID,
      amount: _totalCost,
      method: PaymentMethod.card,
    );
    
    // Refresh app state
    await appState.loadUserData();
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Purchase successful!')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Buy ${widget.stock.symbol}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current Price: \${widget.stock.currentPrice.toStringAsFixed(2)}'),
          SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _calculateTotal(),
          ),
          SizedBox(height: 16),
          Text(
            'Total Cost: \${_totalCost.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text('(includes \$4.95 commission)', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _totalCost > 0 ? _executeBuy : null,
          child: Text('Buy'),
        ),
      ],
    );
  }
}
```

## 5. Testing Approach

### Unit Tests Example
```dart
void main() {
  group('Stock Model Tests', () {
    test('Calculate price change', () {
      final stock = Stock(
        stockID: '1',
        symbol: 'TEST',
        company: 'Test Inc.',
        exchange: 'NYSE',
        currentPrice: 110.0,
        previousClose: 100.0,
        openPrice: 100.0,
        dayHigh: 115.0,
        dayLow: 95.0,
        volume: 1000000,
        marketCap: 1000000000,
      );
      
      expect(stock.calculateChange(), 10.0);
      expect(stock.calculateChangePercent(), 10.0);
    });
  });
  
  group('Portfolio Tests', () {
    test('Calculate total value', () {
      final portfolio = Portfolio(
        portfolioID: 'p1',
        userID: 'u1',
        name: 'Test Portfolio',
      );
      
      final holding = StockHolding(
        holdingID: 'h1',
        portfolioID: 'p1',
        stockID: 's1',
        quantity: 10,
        averagePurchasePrice: 100.0,
        stock: Stock(
          stockID: 's1',
          symbol: 'TEST',
          company: 'Test Inc.',
          exchange: 'NYSE',
          currentPrice: 110.0,
          previousClose: 100.0,
          openPrice: 100.0,
          dayHigh: 115.0,
          dayLow: 95.0,
          volume: 1000000,
          marketCap: 1000000000,
        ),
      );
      
      portfolio.addHolding(holding);
      
      expect(portfolio.totalValue, 1100.0);
      expect(portfolio.totalCost, 1000.0);
      expect(portfolio.totalGainLoss, 100.0);
      expect(portfolio.totalGainLossPercent, 10.0);
    });
  });
}
```

### Widget Tests Example
```dart
void main() {
  testWidgets('StockCard displays correct information', (WidgetTester tester) async {
    final stock = Stock(
      stockID: '1',
      symbol: 'AAPL',
      company: 'Apple Inc.',
      exchange: 'NASDAQ',
      currentPrice: 150.25,
      previousClose: 148.50,
      openPrice: 149.00,
      dayHigh: 151.00,
      dayLow: 148.25,
      volume: 75000000,
      marketCap: 2500000000000,
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StockCard(stock: stock),
        ),
      ),
    );
    
    expect(find.text('AAPL'), findsOneWidget);
    expect(find.text('Apple Inc.'), findsOneWidget);
    expect(find.text('\$150.25'), findsOneWidget);
    expect(find.text('+1.18%'), findsOneWidget);
  });
}
```

## 6. Key Simplifications for University Project

1. **No External Dependencies**
   - All data stored in static lists within service classes
   - No database connections
   - No API calls
   - Mock data initialized on app startup

2. **Simple Authentication**
   - Plain text passwords (for demo only)
   - No encryption or hashing
   - No session management beyond runtime
   - Pre-populated demo users

3. **Simplified Trading**
   - Instant transaction execution
   - Fixed commission rate
   - No complex order types
   - No real payment processing

4. **Basic State Management**
   - Simple Provider pattern
   - No complex state machines
   - Data refreshed manually
   - No real-time updates

5. **Mock Data**
   - Pre-defined stock list
   - Random price movements
   - Demo portfolios
   - Sample transactions

## 7. Running the App

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  // Initialize all demo data
  initializeApp();
  runApp(AlphaWaveApp());
}

void initializeApp() {
  // Services automatically initialize their static data
  PortfolioManagerService.initializeDemoData();
  WatchlistService.initializeDemoData();
  
  // Simulate price changes every 5 seconds
  Timer.periodic(Duration(seconds: 5), (timer) {
    StockDataService.simulatePriceChanges();
  });
}
```

## 8. Demo Credentials

For testing the application:
- Username: `johndoe` / Password: `password123`
- Username: `janesmith` / Password: `password456`

The app comes pre-populated with:
- Sample stock data (AAPL, GOOGL, MSFT, AMZN, TSLA)
- Demo portfolio with some holdings
- Sample watchlist
- Transaction history

This simplified architecture provides a complete learning experience while avoiding the complexity of external dependencies, making it perfect for a university course project.