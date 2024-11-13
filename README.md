# MetaTrader 5 Trading Panel
A MetaTrader 5 trading panel for managing positions and orders with a clean GUI interface.

## 🚧 Development Status
This project is currently in early development. Core features are being built and tested.

## 🎯 Features

### Current Features
* Basic GUI panel
* Position management
* Order placement interface
* Account information display

### Planned Features

#### 🤖 Automated Trading Rules
* Customizable entry conditions:
  * Technical indicator-based rules (EMA, RSI, MACD, etc.)
  * Price action patterns
  * Multiple condition combinations
* Trade execution settings:
  * Position size calculation
  * Entry price types (market/limit/stop)
  * Automatic stop loss and take profit placement
* Rule management:
  * Enable/disable individual rules
  * Rule priority system
  * Trading time filters
  * Maximum open positions per rule

#### 📊 Position Management
* Position modification controls
  * Stop loss/Take profit adjustment
  * Partial position closing
  * Break-even functionality
* Advanced order types
  * Market orders
  * Pending orders
  * OCO orders

#### 🛡️ Risk Management Tools
* Position size calculator
* Risk per trade calculator
* Account exposure monitoring

#### 📈 Trade Analytics
* Open P/L tracking
* Position duration
* Performance metrics

## ⚙️ Installation
Automatic:
1. Download the .ex5 from the releases section.
2. double click it and it should open MT5 automatically.
Manual:
1. Download the repository
2. Copy the EA file to your MT5 Experts folder
3. Copy include files to your MT5 Include folder
4. Restart MetaTrader 5
5. Drag the EA onto your chart

## 📝 Requirements
* MetaTrader 5 Platform
* Algorithmic trading enabled
* Basic understanding of technical indicators and trading conditions

## 💻 Usage
### Setting Up Trading Rules
1. Access the Trading Rules tab in the panel
2. Create a new rule using the "Add Rule" button
3. Configure entry conditions:
   * Select technical indicators
   * Define threshold values
   * Set condition relationships (AND/OR)
4. Set trade parameters:
   * Position size
   * Stop loss/Take profit levels
   * Maximum risk per trade
5. Enable/disable rules as needed

Detailed usage instructions will be expanded as features are implemented.
