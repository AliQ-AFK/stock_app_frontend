# AlphaWave Trading App - Technical Documentation

## 1.0 Introduction

### 1.1 Project Overview

AlphaWave Trading is a comprehensive Flutter-based mobile application designed to provide users with real-time stock market data monitoring, portfolio management, and trading capabilities. The application targets both Android and iOS platforms, delivering a secure, intuitive, and responsive trading experience for users of all experience levels.

The application serves as a complete stock trading platform that enables users to:
- Monitor real-time stock market data and historical trends
- Manage personal investment portfolios 
- Execute buy and sell orders with real-time market prices
- Track portfolio performance and transaction history
- Stay informed with market news and updates
- Maintain personalized watchlists for stock monitoring

### 1.2 Key Features

The AlphaWave Trading app encompasses the following core functional modules:

**Authentication & User Management**
- Secure user registration and login system
- Session-based user management with location detection
- Profile management and account settings

**Real-Time Market Data**
- Live stock quotes and price updates via Finnhub API
- Interactive stock charts with multiple timeframes (1 hour to 1 week)
- Historical stock data visualization with FL Chart integration
- Company profile information including industry, country, and exchange details

**Portfolio Management**
- Real-time portfolio valuation with current market prices
- Profit/loss calculations with percentage tracking
- Comprehensive portfolio statistics and performance metrics
- Transaction history and holdings overview

**Trading Operations**
- Market order execution for buying and selling stocks
- Real-time price validation and order confirmation
- Intelligent position management with average cost basis calculations
- Support for partial sales and position adjustments

**Watchlist & Monitoring**
- Customizable stock watchlists with add/remove functionality
- Bulk delete operations with checkbox-based selection
- Real-time price updates for watched stocks
- Quick navigation to detailed stock information

**News & Information**
- Market news integration with filtering capabilities
- Company-specific news articles and updates
- External website access for company information

**Premium Features**
- Alpha Pro subscription tier
- Enhanced analytics and reporting capabilities
- Advanced market insights and data

### 1.3 Target Audience

The AlphaWave Trading app is designed for a diverse range of users within the investment and trading community:

**Primary Users:**
- **Retail Investors**: Individual investors seeking to manage personal portfolios and execute trades on mobile devices
- **Active Traders**: Users who require real-time market data and quick order execution capabilities
- **Investment Enthusiasts**: Market watchers who want to track stock performance and stay informed about market trends

**Secondary Users:**
- **Beginner Investors**: New users learning about stock trading who need an intuitive, educational platform
- **Portfolio Managers**: Professionals managing client portfolios who require mobile access to market data

**Technical Requirements:**
- Android devices running version 5.0 (Lollipop) and above
- iOS devices running version 12 and above
- Active internet connection for real-time data
- Location services access for country detection and localized features

## 2.0 High-Level Architecture

### 2.1 Architectural Pattern (UI -> Service -> API)

AlphaWave Trading follows a clean, layered architecture that emphasizes separation of concerns and maintainability:

```
┌─────────────────────────────────────────────────────────┐
│                    UI LAYER                             │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │   Screens   │ │   Widgets   │ │   Dialogs   │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                 SERVICE LAYER                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │ FinnhubSvc  │ │ TradingSvc  │ │ NewsSvc     │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │ UserSvc     │ │ PaymentSvc  │ │ StockDataSvc│       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                 EXTERNAL APIS                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │ Finnhub API │ │ Location    │ │ URL         │       │
│  │ (Market Data│ │ Services    │ │ Launcher    │       │
│  │ & News)     │ │ (GPS/Geo)   │ │ (Websites)  │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
└─────────────────────────────────────────────────────────┘
```

**UI Layer Responsibilities:**
- Presentation logic and user interface rendering
- User input handling and validation
- State management for UI components
- Navigation between screens

**Service Layer Responsibilities:**
- Business logic implementation
- External API communication and error handling
- Data transformation and validation
- Caching and performance optimization

**External API Layer:**
- Third-party service integration (Finnhub for market data)
- Device services (GPS, camera, URL launching)
- Network communication and response handling

### 2.2 State Management (The "Session-Only" approach with SessionManager)

AlphaWave Trading implements a custom **session-only state management pattern** using a singleton `SessionManager` class, designed for simplicity and performance:

**Key Characteristics:**
- **In-Memory Storage**: All user data (portfolio, watchlist, session info) stored temporarily in RAM
- **Singleton Pattern**: Single source of truth for application state across all screens
- **Synchronous Operations**: Fast, immediate data access without async/await overhead
- **Session-Based**: Data persists only during app session, cleared on app termination

**SessionManager Core Components:**

```dart
class SessionManager {
  // Singleton instance
  static SessionManager? _instance;
  
  // Core state variables
  UserSession? _currentUser;
  List<PortfolioStock> _portfolio = [];
  List<String> _wishlist = [];
  
  // Key methods
  void startSession(String username)
  List<PortfolioStock> getPortfolio()
  Future<bool> buyStock(String symbol, double quantity, double price)
  bool addToWishlist(String symbol)
}
```

**Benefits:**
- **Performance**: Sub-millisecond data access meets <500ms API response criteria
- **Simplicity**: No complex state management frameworks or databases
- **Real-time Updates**: Immediate UI updates across all screens
- **Memory Efficient**: Minimal memory footprint with automatic cleanup

**Limitations:**
- **Data Persistence**: No data saved between app sessions (by design)
- **Offline Support**: Limited functionality without internet connection
- **Scalability**: Not suitable for large datasets or enterprise-scale applications

### 2.3 Data Flow

The AlphaWave Trading app follows a **unidirectional data flow pattern** that ensures predictable state updates and efficient rendering:

**1. User Interaction Flow:**
```
User Action → UI Component → Service Call → External API → Response Processing → State Update → UI Re-render
```

**2. Real-Time Data Flow:**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Tap      │    │   Service       │    │  SessionManager │
│   (Buy Stock)   │───▶│   buyStock()    │───▶│   updateState() │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ▲                       │                       │
         │                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UI Update     │    │  Finnhub API    │    │   Notify UI     │
│   (Success/Error│◀───│  (Get Price)    │◀───│   Components    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**3. Cross-Screen State Synchronization:**
- **Portfolio Screen** updates automatically when trades execute
- **Watchlist Screen** reflects real-time price changes
- **Dashboard** shows consolidated portfolio performance
- **Stock Detail** screens show current position information

**4. Error Handling Flow:**
```
API Error → Service Exception → User-Friendly Message → UI Feedback (SnackBar/Dialog)
```

**5. Performance Optimizations:**
- **Parallel API Calls**: `Future.wait()` for simultaneous data fetching
- **Selective Updates**: Only affected UI components re-render
- **Caching Strategy**: Temporary caching of API responses during session
- **Debounced Requests**: Prevents excessive API calls during user interactions

This architecture ensures that the application maintains high performance while providing real-time data updates and a responsive user experience across all features and screens.

## 3.0 Project Setup & Configuration

### 3.1 Dependencies (from pubspec.yaml)

AlphaWave Trading utilizes a carefully selected set of Flutter packages to provide comprehensive trading functionality:

**Core Dependencies:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
```

**HTTP & API Integration:**
```yaml
  http: ^1.4.0                    # HTTP client for API requests
  flutter_dotenv: ^5.1.0          # Environment variable management
```

**Data Visualization:**
```yaml
  fl_chart: ^1.0.0               # Interactive charts and graphs
  intl: ^0.20.2                  # Internationalization and date formatting
```

**UI & User Experience:**
```yaml
  font_awesome_flutter: ^10.7.0  # Icon library for enhanced UI
  provider: ^6.1.1               # State management solution
  country_code_picker: ^3.0.0    # Country selection widget
```

**Device Services:**
```yaml
  geolocator: ^10.1.0            # GPS location services
  geocoding: ^2.1.1              # Address/coordinate conversion
  url_launcher: ^6.2.6           # External URL/website launching
  shared_preferences: ^2.2.2     # Local data persistence
```

**Payment Integration:**
```yaml
  pay: ^2.0.0                    # Android/iOS payment processing (test mode)
```

**Development Dependencies:**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0          # Dart code linting rules
```

**Asset Configuration:**
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/
    - assets/images/
    - assets/icons/
    - assets/payment/
    - .env                        # Environment configuration file
```

### 3.2 Environment Setup (the .env file)

AlphaWave Trading uses environment variables for secure API key management and configuration:

**Required Environment Variables:**
```bash
# .env file (create in project root)
FINNHUB_API_KEY=your_finnhub_api_key_here
```

**Environment Setup Steps:**

1. **Create .env file** in the project root directory
2. **Register for Finnhub API** at [https://finnhub.io](https://finnhub.io)
3. **Get your free API key** from the Finnhub dashboard
4. **Add the API key** to your `.env` file:
   ```bash
   FINNHUB_API_KEY=pk_abcd1234567890efghijklmnop
   ```

**Security Considerations:**
- The `.env` file is listed in `.gitignore` to prevent accidental commits
- API keys are loaded using `flutter_dotenv` package for secure access
- Environment variables are accessed via `dotenv.env['VARIABLE_NAME']`
- Never hardcode API keys directly in source code

**Environment Validation:**
The application includes API key validation:
```dart
static bool isApiKeyConfigured() {
  return _apiKey.isNotEmpty && _apiKey != 'your_api_key_here';
}
```

### 3.3 Permissions (for Android and iOS)

AlphaWave Trading requires specific permissions for location services and network access:

**Android Permissions (AndroidManifest.xml):**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Location permissions for country detection -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Internet permission (automatically granted) -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <!-- Application configuration -->
    <application
        android:label="AlphaWave"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Query intents for URL launching -->
        <queries>
            <intent>
                <action android:name="android.intent.action.PROCESS_TEXT"/>
                <data android:mimeType="text/plain"/>
            </intent>
        </queries>
    </application>
</manifest>
```

**iOS Permissions (Info.plist):**
```xml
<dict>
    <!-- App identification -->
    <key>CFBundleDisplayName</key>
    <string>Stock App</string>
    
    <!-- Location permissions with user explanations -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs access to your location to determine your country.</string>
    
    <key>NSLocationAlwaysUsageDescription</key>
    <string>This app needs access to your location to determine your country.</string>
    
    <!-- UI orientation support -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
```

**Permission Handling:**
- **Location**: Required for automatic country detection during user registration
- **Internet**: Required for real-time stock data and API communication
- **URL Launching**: Enables opening company websites in external browser
- **Runtime Requests**: Location permissions are requested dynamically when needed

## 4.0 Core Services Deep Dive

### 4.1 FinnhubService

The `FinnhubService` class provides all external market data functionality through the Finnhub API:

**Configuration Properties:**
```dart
static const String _baseUrl = 'https://finnhub.io/api/v1'
static String get _apiKey => dotenv.env['FINNHUB_API_KEY'] ?? ''
static Map<String, String> get _headers => {'Content-Type': 'application/json'}
```

**Public Methods:**

#### `getStockQuote(String symbol) → Future<Map<String, dynamic>?>`
- **Purpose**: Fetches real-time stock price and trading data
- **Parameters**: 
  - `symbol` (String): Stock ticker symbol (e.g., 'AAPL', 'GOOGL')
- **Returns**: Map containing current price (c), change (d), percent change (dp), high (h), low (l), open (o), previous close (pc)
- **Error Handling**: Returns null on error, logs status codes

#### `getCompanyProfile(String symbol) → Future<Map<String, dynamic>?>`
- **Purpose**: Retrieves company information and profile data
- **Parameters**: 
  - `symbol` (String): Stock ticker symbol
- **Returns**: Map with company name, country, exchange, industry, logo URL, website URL
- **Special Handling**: Throws specific exception for 403 (rate limit) errors

#### `getStockCandles({required String symbol, required String resolution, required int from, required int to}) → Future<Map<String, dynamic>?>`
- **Purpose**: Fetches historical price data for chart rendering
- **Parameters**: 
  - `symbol` (String): Stock ticker symbol
  - `resolution` (String): Time resolution ('1', '5', '15', '30', '60', 'D', 'W', 'M')
  - `from` (int): Start timestamp (Unix format)
  - `to` (int): End timestamp (Unix format)
- **Returns**: Candle data with open, high, low, close, volume arrays
- **Usage**: Powers the interactive stock charts in detail screens

#### `searchStocks(String query) → Future<Map<String, dynamic>>`
- **Purpose**: Searches for stocks matching query string
- **Parameters**: 
  - `query` (String): Search term (symbol or company name)
- **Returns**: Map containing array of matching stocks with symbols and descriptions
- **Error Handling**: Throws Exception on failure

#### `getQuote(String symbol) → Future<Map<String, dynamic>>`
- **Purpose**: Alternative quote method with exception throwing
- **Parameters**: 
  - `symbol` (String): Stock ticker symbol
- **Returns**: Current price data map
- **Error Handling**: Throws Exception instead of returning null

#### `getBasicFinancials(String symbol) → Future<Map<String, dynamic>>`
- **Purpose**: Retrieves fundamental financial metrics
- **Parameters**: 
  - `symbol` (String): Stock ticker symbol
- **Returns**: Financial ratios including P/E, market cap, beta, EPS
- **Usage**: Powers the fundamentals section in stock detail screens

#### `getCompanyNews(String symbol) → Future<List<dynamic>>`
- **Purpose**: Fetches recent company-specific news articles
- **Parameters**: 
  - `symbol` (String): Stock ticker symbol
- **Returns**: List of news articles from the last 7 days
- **Date Range**: Automatically queries past 7 days using DateFormat

#### `getMarketNews({String category = 'general', String? minId}) → Future<List<dynamic>?>`
- **Purpose**: Retrieves general market news and updates
- **Parameters**: 
  - `category` (String): News category ('general', 'forex', 'crypto', 'merger')
  - `minId` (String?): Optional pagination parameter
- **Returns**: List of market news articles
- **Error Handling**: Returns null on error with status code logging

#### `isApiKeyConfigured() → bool`
- **Purpose**: Validates that API key is properly set
- **Parameters**: None
- **Returns**: true if API key exists and is not placeholder
- **Usage**: Used in initialization to verify configuration

#### `getApiUsage() → Future<Map<String, dynamic>?>`
- **Purpose**: Monitors API usage and rate limits
- **Parameters**: None
- **Returns**: Map with usage statistics and remaining quota
- **Usage**: For debugging and monitoring API consumption

### 4.2 SessionManager

The `SessionManager` implements the singleton pattern for in-memory state management:

**Core Properties:**
```dart
static SessionManager? _instance
UserSession? _currentUser
List<PortfolioStock> _portfolio = []
List<String> _wishlist = []
```

**Public Methods:**

#### `SessionManager() → SessionManager`
- **Purpose**: Factory constructor implementing singleton pattern
- **Parameters**: None
- **Returns**: Single instance of SessionManager
- **Usage**: `final sessionManager = SessionManager()`

#### `startSession(String username) → void`
- **Purpose**: Initializes new user session and clears previous data
- **Parameters**: 
  - `username` (String): User identifier for the session
- **Returns**: void
- **Side Effects**: Clears portfolio and wishlist, creates new UserSession

#### `endSession() → void`
- **Purpose**: Terminates current session and clears all data
- **Parameters**: None
- **Returns**: void
- **Side Effects**: Resets all state variables to empty/null

#### `getPortfolio() → List<PortfolioStock>`
- **Purpose**: Retrieves current portfolio holdings
- **Parameters**: None
- **Returns**: Copy of portfolio list to prevent external modification
- **Performance**: Synchronous operation for fast UI binding

#### `getWishlist() → List<String>`
- **Purpose**: Retrieves current watchlist symbols
- **Parameters**: None
- **Returns**: Copy of wishlist to prevent external modification
- **Performance**: Synchronous operation for immediate access

#### `buyStock(String symbol, double quantity, double purchasePrice) → Future<bool>`
- **Purpose**: Executes stock purchase and updates portfolio
- **Parameters**: 
  - `symbol` (String): Stock ticker symbol
  - `quantity` (double): Number of shares to purchase
  - `purchasePrice` (double): Price per share
- **Returns**: true if successful, false on error
- **Logic**: Handles both new positions and existing position updates with average cost calculation

#### `sellStock(String symbol, double quantity) → bool`
- **Purpose**: Executes stock sale and updates portfolio
- **Parameters**: 
  - `symbol` (String): Stock ticker symbol
  - `quantity` (double): Number of shares to sell
- **Returns**: true if successful, false on insufficient shares
- **Logic**: Supports partial sales and complete position removal

#### `addToWishlist(String symbol) → bool`
- **Purpose**: Adds stock to watchlist
- **Parameters**: 
  - `symbol` (String): Stock ticker symbol
- **Returns**: true if added, false if already exists
- **Behavior**: Prevents duplicate entries and converts to uppercase

#### `removeFromWishlist(String symbol) → bool`
- **Purpose**: Removes stock from watchlist
- **Parameters**: 
  - `symbol` (String): Stock ticker symbol
- **Returns**: true if removed, false if not found
- **Usage**: Supports bulk delete operations in UI

#### `isInWishlist(String symbol) → bool`
- **Purpose**: Checks if stock is in current watchlist
- **Parameters**: 
  - `symbol` (String): Stock ticker symbol
- **Returns**: true if symbol is in wishlist
- **Usage**: Updates UI star/heart icons

#### `getPortfolioSummary() → Map<String, double>`
- **Purpose**: Calculates portfolio summary statistics
- **Parameters**: None
- **Returns**: Map with totalCost, totalStocks count
- **Performance**: Synchronous calculation for dashboard display

#### `calculateTotalPortfolioValue() → Future<double>`
- **Purpose**: Calculates real-time portfolio market value
- **Parameters**: None
- **Returns**: Total portfolio value using current market prices
- **API Calls**: Fetches current prices for all holdings via FinnhubService

#### `calculatePortfolioProfitLoss() → Future<Map<String, double>>`
- **Purpose**: Calculates portfolio profit/loss with real-time prices
- **Parameters**: None
- **Returns**: Map with 'amount' and 'percentage' profit/loss values
- **Logic**: Compares current market value vs. cost basis

#### `fetchAndSaveLocation() → Future<String>`
- **Purpose**: Gets user's country via LocationService and saves to session
- **Parameters**: None
- **Returns**: ISO country code (e.g., 'US', 'CA')
- **Error Handling**: Throws exceptions for permission/service issues

#### `getDetectedCountry() → String?`
- **Purpose**: Retrieves previously detected country from session
- **Parameters**: None
- **Returns**: Country code or null if not detected
- **Usage**: Avoids repeated location requests

#### `clearAllData() → void`
- **Purpose**: Development/testing method to reset all data
- **Parameters**: None
- **Returns**: void
- **Usage**: Debugging and testing scenarios

#### `printSessionState() → void`
- **Purpose**: Debug method to log current session state
- **Parameters**: None
- **Returns**: void
- **Output**: Prints user, portfolio, and wishlist information to console

### 4.3 LocationService

The `LocationService` handles GPS-based country detection:

**Public Methods:**

#### `getCountry() → Future<String>`
- **Purpose**: Determines user's country using GPS coordinates
- **Parameters**: None
- **Returns**: ISO country code (e.g., 'US', 'CA', 'UK')
- **Process**: 
  1. Checks location service availability
  2. Requests/validates permissions
  3. Gets GPS coordinates with 15-second timeout
  4. Converts coordinates to address with 10-second timeout
  5. Extracts country code from placemark data
- **Error Handling**: Comprehensive error categorization with user-friendly messages
- **Timeouts**: Prevents hanging requests with configurable timeouts

#### `isLocationServiceEnabled() → Future<bool>`
- **Purpose**: Checks if device GPS services are enabled
- **Parameters**: None
- **Returns**: true if location services are available
- **Usage**: Pre-flight check before requesting location
- **Error Handling**: Returns false on any exception

#### `getPermissionStatus() → Future<LocationPermission>`
- **Purpose**: Retrieves current location permission status
- **Parameters**: None
- **Returns**: LocationPermission enum value
- **States**: denied, deniedForever, whileInUse, always
- **Usage**: UI can show appropriate permission request messages

**Error Categories:**
- **Permission Errors**: User denied location access
- **Service Errors**: GPS disabled on device
- **Timeout Errors**: Network or GPS signal issues
- **Network Errors**: Geocoding service unavailable
- **Data Errors**: Invalid or empty location data

## 5.0 Screen & Widget Breakdown

This section provides comprehensive documentation of all major screens in the AlphaWave Trading application, detailing their purpose, state management, key functionality, and service integrations.

### 5.1 Authentication Screens

#### **LandingScreen**
- **Purpose**: Initial entry point with authentication options and theme-aware welcome interface
- **State Variables**: 
  - `brightness` - Current theme mode from ThemeProvider
  - `isLightMode` - Boolean for background image selection
- **Key Methods**: 
  - Navigation to SignInScreen and SignUp1Screen
- **UI Data Mapping**: 
  - Dynamic background image based on theme (light_first_page.jpeg / dark_first_page.jpeg)
  - Theme-aware button styling and text colors
- **Service Integration**: ThemeProvider for automatic theme switching

#### **SignInScreen / SignUpScreen**
- **Purpose**: User authentication with credential validation and session initiation
- **State Variables**:
  - Form controllers for email/password input
  - Validation states and error messages
  - Loading indicators during authentication
- **Key Methods**:
  - `_handleSignIn()` - Processes user credentials
  - `_validateForm()` - Client-side validation
  - Session initialization via SessionManager
- **Service Integration**: 
  - SessionManager for user session creation
  - LocationService for country detection on registration

### 5.2 Dashboard & Portfolio Screens

#### **DashboardScreen**
- **Purpose**: Main hub displaying portfolio overview, trending stocks, news, and watchlist with real-time data
- **State Variables**:
  ```dart
  List<Stock> _myStocks = [];
  List<Stock> _trendingStocks = [];
  List<NewsArticle> _latestNews = [];
  List<Stock> _watchlistStocks = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> newTrendingStocks = [];
  bool isLoadingTrending = true;
  ```
- **Key Methods**:
  - `_loadDashboardData()` - Fetches all dashboard content using Future.wait for performance
  - `_fetchTrendingData()` - Gets real-time trending stock prices
  - `_refreshData()` - Pull-to-refresh functionality
  - `_buildPortfolioSummaryCard()` - Real-time portfolio valuation display
- **UI Data Mapping**:
  - **Portfolio Summary**: Real-time value via `SessionManager.calculateTotalPortfolioValue()`
  - **My Stocks**: Portfolio data converted to Stock objects with current prices
  - **Trending Stocks**: Live data from FinnhubService for popular symbols
  - **News**: Hard-coded news matching design specifications
  - **Watchlist**: User's saved stocks with current market data
- **Service Integration**:
  - **FinnhubService**: Real-time quotes, company profiles
  - **SessionManager**: Portfolio and watchlist data retrieval
  - **StockDataService**: Stock information processing

#### **PortfolioScreen**
- **Purpose**: Detailed portfolio view with comprehensive holdings analysis and performance metrics
- **State Variables**:
  ```dart
  bool _isPro = false;
  bool _isLoading = false;
  List<Stock> _portfolioStocks = [];
  List<Stock> _watchlistStocks = [];
  ```
- **Key Methods**:
  - `_loadStockData()` - Converts portfolio holdings to Stock objects with current prices
  - `_checkProStatus()` - Validates premium subscription status
  - `_buildTotalPortfolioValueCard()` - Portfolio summary with profit/loss calculations
- **UI Data Mapping**:
  - **Total Portfolio Value**: FutureBuilder with `SessionManager.calculateTotalPortfolioValue()`
  - **Profit/Loss**: Dynamic color coding based on performance
  - **Holdings Display**: Horizontal scrollable stock cards with current market data
  - **Pro Features**: Conditional UI elements based on subscription status
- **Service Integration**:
  - **SessionManager**: Portfolio data and profit/loss calculations
  - **PaymentService**: Pro status verification
  - **FinnhubService**: Current market prices for holdings

### 5.3 Stock-Related Screens

#### **StockDetailScreen**
- **Purpose**: Comprehensive stock analysis with charts, financials, news, and trading functionality
- **State Variables**:
  ```dart
  bool isLoading = true;
  Map<String, dynamic>? quoteData;
  Map<String, dynamic>? profileData;
  Map<String, dynamic>? financialData;
  List<double>? chartDataPoints;
  List<int>? chartTimestamps;
  bool isChartLoading = true;
  Color chartColor = Colors.grey;
  int _selectedDays = 90;
  bool _isInWatchlist = false;
  bool _isProfileExpanded = false;
  ```
- **Key Methods**:
  - `_fetchStockDetails()` - Parallel data fetching with Future.wait for optimal performance
  - `_updateChart(int days)` - Dynamic chart data based on timeframe selection
  - `_handleBuyStock()` / `_handleSellStock()` - Trading dialog navigation
  - `_toggleWatchlist()` - Add/remove from user's watchlist
  - `_launchCompanyWebsite()` - External website integration
- **UI Data Mapping**:
  - **Stock Quote**: Real-time price, change, volume from FinnhubService
  - **Charts**: Historical price data with dynamic timeframes (1D, 7D, 30D, 90D)
  - **Company Profile**: Business information, industry, exchange details
  - **Financials**: P/E ratio, market cap, financial metrics
  - **News Tab**: Company-specific news articles
  - **Trading Buttons**: Context-aware buy/sell based on user's holdings
- **Service Integration**:
  - **FinnhubService**: Quote, profile, financials, candle data, company news
  - **SessionManager**: Watchlist management, portfolio position checking
  - **URL Launcher**: Company website access

#### **StockSearchScreen**
- **Purpose**: Real-time stock search with debounced API calls and intelligent result filtering
- **State Variables**:
  ```dart
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasText = false;
  Map<String, String> _logoCache = {};
  ```
- **Key Methods**:
  - `_onSearchChanged(String query)` - 500ms debounced search trigger
  - `_performSearch(String query)` - FinnhubService.searchStocks API integration
  - `_buildStockResultItem()` - Individual search result with company logo
  - `_fetchCompanyLogo()` - Cached logo retrieval with fallback icons
- **UI Data Mapping**:
  - **Search Results**: Symbol, company description, type from Finnhub search API
  - **Company Logos**: Dynamic logo fetching with intelligent caching
  - **Empty States**: Context-aware messages for different search states
- **Service Integration**:
  - **FinnhubService**: Stock search API with result filtering
  - **Caching**: Logo cache for performance optimization

#### **BuyStockScreen / SellStockScreen**
- **Purpose**: Trading execution with Google Pay integration and real-time price validation
- **State Variables**:
  ```dart
  int _quantity = 1;
  bool _isProcessing = false;
  bool _showGooglePay = false;
  late final Future<String> _googlePayConfigFuture;
  ```
- **Key Methods**:
  - `_handleConfirmPress()` - Two-step trading flow initiation
  - `_onPaymentResult()` - Google Pay callback processing
  - `_loadGooglePayConfig()` - Dynamic payment configuration
  - Quantity adjustment methods with validation
- **UI Data Mapping**:
  - **Price Calculation**: Real-time total based on current market price × quantity
  - **Payment Integration**: Google Pay button with dynamic amount
  - **Confirmation Flow**: Two-step process for security
- **Service Integration**:
  - **SessionManager**: Portfolio updates via buyStock/sellStock methods
  - **Google Pay**: Integrated payment processing for mock transactions

### 5.4 News & Information Screens

#### **NewsScreen**
- **Purpose**: Market news and trending stocks with hard-coded content matching design specifications
- **State Variables**:
  ```dart
  final List<String> popularSymbols = ['TSLA', 'AAPL', 'NVDA', 'AMD', 'META'];
  List<Map<String, dynamic>> trendingStocks = [];
  bool isLoadingTrending = true;
  late List<HardCodedNewsItem> hardCodedNews;
  bool _isPro = false;
  ```
- **Key Methods**:
  - `_fetchTrendingData()` - Real-time trending stock data
  - `_initializeHardCodedNews()` - Theme-aware news data initialization
  - `_buildTrendingStocksCarousel()` - Horizontal scrollable trending stocks
  - `_buildHardCodedNewsList()` - News articles with source attribution
- **UI Data Mapping**:
  - **Trending Stocks**: Real-time prices and percentage changes from FinnhubService
  - **News Articles**: Hard-coded content with source images and badges
  - **Pro Badge**: Conditional display based on subscription status
- **Service Integration**:
  - **FinnhubService**: Real-time quotes for trending stocks
  - **PaymentService**: Pro status verification

### 5.5 Watchlist & Management Screens

#### **WatchlistScreen**
- **Purpose**: User's stock watchlist with bulk delete functionality and real-time price updates
- **State Variables**:
  ```dart
  List<String> _watchlistSymbols = [];
  Map<String, Map<String, dynamic>> _stockData = {};
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isDeleteMode = false;
  Set<String> _selectedForDelete = {};
  ```
- **Key Methods**:
  - `_loadWatchlistData()` - Fetches watchlist from SessionManager with current prices
  - `_toggleDeleteMode()` - Switches between view and delete modes
  - `_deleteSelected()` - Bulk removal of selected stocks
  - `_buildBigWatchlistCard()` - Individual stock cards with selection capability
- **UI Data Mapping**:
  - **Stock Cards**: Symbol, current price, percentage change with color coding
  - **Delete Mode**: Checkbox selection with visual feedback
  - **Empty State**: Encourages user to add stocks via search
- **Service Integration**:
  - **SessionManager**: Watchlist management (add/remove operations)
  - **FinnhubService**: Current quotes and company profiles for watchlist items

### 5.6 Profile & Settings Screens

#### **MyAccountScreen**
- **Purpose**: User profile management, settings, and account preferences with location services
- **State Variables**:
  ```dart
  bool _isPro = false;
  bool _isLoading = true;
  bool _isLocationLoading = false;
  ```
- **Key Methods**:
  - `_checkProStatus()` - Premium subscription verification
  - `_fetchLocation()` - GPS-based country detection
  - `_getLocationDisplayText()` - Current location status display
  - `_showLocationDialog()` - Location settings management
  - Various dialog methods for settings management
- **UI Data Mapping**:
  - **Profile Section**: User info with Pro badge integration
  - **Pro Banner**: Dynamic display based on subscription status
  - **Menu Items**: Theme settings, location, logout, account management
  - **Location Status**: Real-time country detection display
- **Service Integration**:
  - **PaymentService**: Pro status management
  - **SessionManager**: Location data and session management
  - **LocationService**: GPS-based country detection
  - **ThemeProvider**: Theme switching functionality

### 5.7 Data Flow Patterns

**Common Patterns Across Screens:**
1. **Loading States**: Consistent use of `_isLoading` boolean with CircularProgressIndicator
2. **Error Handling**: Try-catch blocks with user-friendly SnackBar messages
3. **Real-time Updates**: FutureBuilder and setState for dynamic content
4. **Theme Awareness**: All screens use AppColors with brightness detection
5. **Navigation**: Consistent push/pop patterns with result handling
6. **SessionManager Integration**: Synchronized state across screens for portfolio and watchlist
7. **API Integration**: Consistent error handling and fallback strategies
8. **Performance Optimization**: Future.wait for parallel API calls, debounced search, caching strategies

This comprehensive screen breakdown demonstrates the application's adherence to the session-only state management approach while providing rich, real-time functionality across all user interfaces.

## 6.0 User Flow

This section outlines the primary user journeys through the AlphaWave Trading application, demonstrating how users navigate from initial app launch to core trading functionality.

### 6.1 Primary User Journey: First-Time User

**Step 1: App Launch & Authentication**
```
LandingScreen → SignUpScreen (SignUp1 + SignUp2) → Location Detection → DashboardScreen
```

1. **LandingScreen**: User sees theme-aware welcome interface
   - Chooses between "Sign In" or "Sign Up"
   - Background adapts to system theme preference

2. **SignUp1Screen**: Basic information collection
   - Email and password entry with validation
   - Real-time form validation feedback
   - Navigation to second signup step

3. **SignUp2Screen**: Extended profile setup
   - Additional user information
   - Country selection with phone number formatting
   - LocationService integration for automatic country detection

4. **Session Initialization**: Behind-the-scenes setup
   - SessionManager creates new user session
   - Location detection via GPS (with user permission)
   - Initial portfolio and watchlist initialization (empty)

5. **DashboardScreen**: Main application hub
   - Portfolio summary card (shows $0.00 for new users)
   - Empty states for "My Stocks" and "My Watchlist"
   - Trending stocks with real-time data
   - Latest news (hard-coded content)

### 6.2 Core User Journey: Stock Discovery & Trading

**Step 2: Stock Discovery**
```
DashboardScreen → StockSearchScreen → StockDetailScreen → BuyStockScreen → Portfolio Updated
```

1. **Stock Search**: User discovers investments
   - Tap search icon from Dashboard header
   - Enter stock symbol or company name
   - Debounced search (500ms) with real-time results
   - Company logos with intelligent caching

2. **Stock Analysis**: Comprehensive research
   - Real-time price and market data from FinnhubService
   - Interactive charts with multiple timeframes (1D, 7D, 30D, 90D)
   - Company profile information and financial metrics
   - News tab with company-specific articles
   - "Visit Company Website" button for external research

3. **Trading Decision**: Add to watchlist or purchase
   - **Option A**: Add to watchlist (star icon) for monitoring
   - **Option B**: Proceed with purchase via "Buy" button

4. **Purchase Flow**: Secure transaction process
   - BuyStockScreen dialog with quantity selection
   - Real-time price calculation (quantity × current price)
   - Two-step confirmation process
   - Google Pay integration for mock payment
   - SessionManager portfolio update

### 6.3 Portfolio Management Journey

**Step 3: Portfolio Monitoring & Management**
```
DashboardScreen → PortfolioScreen → MyStocksScreen → StockDetailScreen → SellStockScreen
```

1. **Portfolio Overview**: High-level performance tracking
   - Portfolio summary card on Dashboard
   - Real-time total value calculation
   - Profit/loss with dynamic color coding
   - "Companies" count display

2. **Detailed Portfolio View**: Comprehensive analysis
   - PortfolioScreen with expanded metrics
   - Total portfolio value with profit/loss percentage
   - Performance indicators and risk assessment
   - Horizontal scrollable holdings display

3. **Individual Holdings**: Stock-level management
   - MyStocksScreen with detailed holdings list
   - Current value vs. cost basis comparison
   - Quantity owned and average purchase price
   - Direct navigation to stock detail screens

4. **Selling Process**: Position management
   - SellStockScreen with quantity selection
   - Real-time value calculation for sale
   - Partial or complete position closure
   - Portfolio rebalancing after sale

### 6.4 Information & Monitoring Journey

**Step 4: Market Research & News Consumption**
```
DashboardScreen → NewsScreen → WatchlistScreen → NotificationScreen
```

1. **News Consumption**: Market awareness
   - Latest news section on Dashboard (first 2 articles)
   - Full NewsScreen with trending stocks carousel
   - Hard-coded news articles with source attribution
   - Real-time trending stock prices and changes

2. **Watchlist Management**: Stock monitoring
   - WatchlistScreen with user's saved stocks
   - Real-time price updates for all watched stocks
   - Bulk delete functionality with checkbox selection
   - Quick navigation to stock detail screens

3. **Notifications**: Updates and alerts
   - NotificationScreen for app notifications
   - System-level notification management
   - Alert preferences and settings

### 6.5 Profile & Settings Journey

**Step 5: Account Management & Personalization**
```
DashboardScreen → MyAccountScreen → Settings/Preferences → AlphaProScreen
```

1. **Profile Management**: User account settings
   - MyAccountScreen with profile information
   - Location detection and country settings
   - Theme switching (light/dark mode)
   - Account preferences and privacy settings

2. **Premium Features**: Subscription management
   - AlphaProScreen for premium feature access
   - PaymentService integration for subscription management
   - Pro badge display across applicable screens
   - Enhanced features for premium users

3. **App Settings**: Customization options
   - Theme preferences with system integration
   - Currency settings for international users
   - Notification preferences
   - Account security settings

### 6.6 Navigation Patterns

**Primary Navigation**: Bottom navigation bar (MainScreen)
- **Dashboard**: Home hub with overview
- **News**: Market news and trending stocks  
- **Portfolio**: Detailed portfolio management
- **Profile**: Account settings and preferences

**Secondary Navigation**: Context-aware actions
- **Search**: Accessible from multiple screens via header
- **Notifications**: Bell icon in screen headers
- **Back Navigation**: Consistent arrow_back icons
- **Deep Links**: Direct navigation to stock details

**Data Persistence Flow**:
```
User Action → UI Update → SessionManager → In-Memory Storage → Cross-Screen Sync
```

**Error Handling Flow**:
```
API Error → Service Exception → User-Friendly Message → Recovery Options
```

This user flow demonstrates the application's intuitive design, guiding users from discovery through execution while maintaining consistent navigation patterns and real-time data synchronization across all screens.

## 7.0 Future Work & Improvements

This section outlines planned enhancements and architectural improvements for the AlphaWave Trading application, addressing current limitations and expanding functionality.

### 7.1 Database Implementation & Data Persistence

**Current Limitation**: Session-only storage results in data loss when app terminates

**Planned Implementation**:

#### **7.1.1 Database Architecture**
```sql
-- User Management
CREATE TABLE users (
    id UUID PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    country_code VARCHAR(2),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Portfolio Holdings
CREATE TABLE portfolio_holdings (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    symbol VARCHAR(10) NOT NULL,
    quantity DECIMAL(15,6) NOT NULL,
    average_cost DECIMAL(15,2) NOT NULL,
    purchase_date TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Watchlist Management
CREATE TABLE watchlists (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    symbol VARCHAR(10) NOT NULL,
    added_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, symbol)
);

-- Transaction History
CREATE TABLE transactions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    symbol VARCHAR(10) NOT NULL,
    transaction_type ENUM('buy', 'sell') NOT NULL,
    quantity DECIMAL(15,6) NOT NULL,
    price DECIMAL(15,2) NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    executed_at TIMESTAMP DEFAULT NOW()
);
```

#### **7.1.2 Data Layer Refactoring**
```dart
// Replace SessionManager with Repository pattern
abstract class PortfolioRepository {
  Future<List<PortfolioHolding>> getUserPortfolio(String userId);
  Future<bool> addPosition(String userId, String symbol, double quantity, double price);
  Future<bool> updatePosition(String userId, String symbol, double newQuantity);
  Future<bool> removePosition(String userId, String symbol);
}

class DatabasePortfolioRepository implements PortfolioRepository {
  final Database _database;
  
  @override
  Future<List<PortfolioHolding>> getUserPortfolio(String userId) async {
    // SQLite/Firebase implementation
  }
}
```

**Benefits**:
- **Data Persistence**: User data survives app restarts
- **Offline Capability**: Local database with sync capabilities
- **Performance**: Cached data reduces API calls
- **Scalability**: Supports larger datasets and user growth

### 7.2 State Management Architecture Upgrade

**Current Limitation**: Custom SessionManager doesn't scale for complex state scenarios

**Planned Implementation**:

#### **7.2.1 Bloc Pattern Integration**
```dart
// Portfolio State Management
class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final PortfolioRepository _repository;
  final FinnhubService _finnhubService;

  PortfolioBloc(this._repository, this._finnhubService) : super(PortfolioInitial()) {
    on<LoadPortfolio>(_onLoadPortfolio);
    on<AddStock>(_onAddStock);
    on<SellStock>(_onSellStock);
  }

  Future<void> _onLoadPortfolio(LoadPortfolio event, Emitter<PortfolioState> emit) async {
    emit(PortfolioLoading());
    try {
      final holdings = await _repository.getUserPortfolio(event.userId);
      final portfolioWithPrices = await _enrichWithCurrentPrices(holdings);
      emit(PortfolioLoaded(portfolioWithPrices));
    } catch (e) {
      emit(PortfolioError(e.toString()));
    }
  }
}
```

**Benefits**:
- **Separation of Concerns**: Business logic separated from UI
- **Testability**: Easy unit testing of business logic
- **Predictable State**: Unidirectional data flow
- **Debugging**: Better state tracking and debugging tools

### 7.3 Real-Time Data Enhancements

**Current Limitation**: Manual refresh for price updates

**Planned Implementation**:

#### **7.3.1 WebSocket Integration**
```dart
class RealTimeStockService {
  StreamSubscription<dynamic>? _wsSubscription;
  final StreamController<StockPriceUpdate> _priceController = StreamController.broadcast();

  Stream<StockPriceUpdate> get priceUpdates => _priceController.stream;

  Future<void> subscribeToSymbols(List<String> symbols) async {
    final wsUrl = 'wss://ws.finnhub.io?token=${Environment.finnhubApiKey}';
    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    
    // Subscribe to symbols
    for (final symbol in symbols) {
      channel.sink.add(json.encode({'type': 'subscribe', 'symbol': symbol}));
    }

    _wsSubscription = channel.stream.listen((data) {
      final decoded = json.decode(data);
      if (decoded['type'] == 'trade') {
        _priceController.add(StockPriceUpdate.fromJson(decoded));
      }
    });
  }
}
```

#### **7.3.2 Background Sync Service**
```dart
class BackgroundSyncService {
  static const String taskName = 'portfolioSync';

  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> schedulePortfolioSync() async {
    await Workmanager().registerPeriodicTask(
      taskName,
      'syncPortfolioData',
      frequency: Duration(minutes: 15),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Background portfolio synchronization
    final portfolioService = GetIt.instance<PortfolioService>();
    await portfolioService.syncWithServer();
    return Future.value(true);
  });
}
```

### 7.4 Enhanced Trading Features

#### **7.4.1 Advanced Order Types**
```dart
enum OrderType { market, limit, stopLoss, stopLimit }
enum OrderDuration { day, gtc, ioc, fok }

class TradingOrder {
  final String symbol;
  final OrderType type;
  final OrderSide side;
  final double quantity;
  final double? limitPrice;
  final double? stopPrice;
  final OrderDuration duration;
  final DateTime expiresAt;
}

class AdvancedTradingService {
  Future<OrderResult> placeLimitOrder(String symbol, double quantity, double limitPrice) async {
    // Implement limit order logic
  }

  Future<OrderResult> placeStopLoss(String symbol, double quantity, double stopPrice) async {
    // Implement stop-loss order logic
  }
}
```

#### **7.4.2 Portfolio Analytics**
```dart
class PortfolioAnalytics {
  double calculateSharpeRatio(List<PortfolioHolding> holdings);
  double calculateBeta(List<PortfolioHolding> holdings);
  AssetAllocation getAssetAllocation(List<PortfolioHolding> holdings);
  RiskMetrics calculateRiskMetrics(List<PortfolioHolding> holdings);
  
  List<Recommendation> generateRebalancingRecommendations(
    List<PortfolioHolding> holdings,
    Map<String, double> targetAllocation,
  );
}
```

### 7.5 Performance Optimizations

#### **7.5.1 Caching Strategy**
```dart
class MultiLevelCacheService {
  final Map<String, dynamic> _memoryCache = {};
  final Database _diskCache;
  final Duration _memoryTTL = Duration(minutes: 5);
  final Duration _diskTTL = Duration(hours: 1);

  Future<T?> get<T>(String key) async {
    // 1. Check memory cache
    if (_memoryCache.containsKey(key)) {
      final cached = _memoryCache[key];
      if (cached.expiry.isAfter(DateTime.now())) {
        return cached.data as T;
      }
    }

    // 2. Check disk cache
    final diskCached = await _diskCache.get(key);
    if (diskCached != null && diskCached.expiry.isAfter(DateTime.now())) {
      _memoryCache[key] = diskCached;
      return diskCached.data as T;
    }

    return null;
  }
}
```

#### **7.5.2 Image Optimization**
```dart
class OptimizedImageService {
  static const String _cacheDir = 'company_logos';
  
  Future<Widget> getCachedLogo(String symbol) async {
    final cacheKey = 'logo_${symbol.toLowerCase()}';
    final cachedPath = await _getCachedImagePath(cacheKey);
    
    if (cachedPath != null) {
      return Image.file(File(cachedPath));
    }
    
    return FutureBuilder<String>(
      future: _downloadAndCacheLogo(symbol, cacheKey),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.file(File(snapshot.data!));
        }
        return _buildFallbackLogo(symbol);
      },
    );
  }
}
```

### 7.6 Testing Strategy Implementation

#### **7.6.1 Comprehensive Test Suite**
```dart
// Unit Tests
class PortfolioServiceTest {
  @Test
  void shouldCalculateTotalValueCorrectly() async {
    // Given
    final mockRepository = MockPortfolioRepository();
    final mockPriceService = MockPriceService();
    final service = PortfolioService(mockRepository, mockPriceService);
    
    // When
    final totalValue = await service.calculateTotalValue('user123');
    
    // Then
    expect(totalValue, equals(15000.00));
  }
}

// Integration Tests
class TradingFlowTest {
  @IntegrationTest
  void shouldCompleteBuyOrderSuccessfully() async {
    // End-to-end trading flow test
  }
}

// Widget Tests
class DashboardScreenTest {
  @WidgetTest
  void shouldShowPortfolioSummaryWhenDataLoaded() async {
    // Widget rendering and interaction tests
  }
}
```

#### **7.6.2 Automated Testing Pipeline**
```yaml
# .github/workflows/flutter_tests.yml
name: Flutter Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter test integration_test/
```

### 7.7 Security Enhancements

#### **7.7.1 API Key Management**
```dart
class SecureConfigService {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> storeApiKey(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  static Future<String?> getApiKey(String key) async {
    return await _storage.read(key: key);
  }
}
```

#### **7.7.2 Authentication Upgrade**
```dart
class JWTAuthService {
  Future<AuthResult> signInWithCredentials(String email, String password) async {
    final response = await _httpClient.post('/auth/login', {
      'email': email,
      'password': password,
    });
    
    if (response.statusCode == 200) {
      final jwt = response.data['token'];
      await SecureConfigService.storeApiKey('auth_token', jwt);
      return AuthResult.success(User.fromJson(response.data['user']));
    }
    
    return AuthResult.failure(response.data['message']);
  }
}
```

### 7.8 Deployment & DevOps Improvements

#### **7.8.1 CI/CD Pipeline**
```yaml
# Automated build and deployment
stages:
  - analyze
  - test
  - build
  - deploy

deploy_production:
  stage: deploy
  script:
    - flutter build apk --release
    - flutter build ios --release
    - fastlane android deploy
    - fastlane ios deploy
  only:
    - main
```

#### **7.8.2 Monitoring & Analytics**
```dart
class AppAnalytics {
  static Future<void> trackUserAction(String action, Map<String, dynamic> parameters) async {
    await FirebaseAnalytics.instance.logEvent(
      name: action,
      parameters: parameters,
    );
  }
  
  static Future<void> trackError(String error, StackTrace stackTrace) async {
    await FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
```

### 7.9 Implementation Timeline

**Phase 1 (Q1)**: Foundation & Database
- Database schema implementation
- Repository pattern migration
- Basic data persistence

**Phase 2 (Q2)**: State Management & Real-time Data
- Bloc pattern implementation
- WebSocket integration for live prices
- Background sync service

**Phase 3 (Q3)**: Advanced Features
- Enhanced trading functionality
- Portfolio analytics
- Performance optimizations

**Phase 4 (Q4)**: Polish & Production
- Comprehensive testing suite
- Security enhancements
- Production deployment pipeline

This roadmap transforms AlphaWave Trading from a session-based prototype into a production-ready trading platform while maintaining the clean architecture and user experience that defines the current implementation.

---

*This documentation is a living document and will be updated as new features and sections are added to the AlphaWave Trading application.* 