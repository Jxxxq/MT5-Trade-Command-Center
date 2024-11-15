//+------------------------------------------------------------------+
//|                                             ModernMainPanelEA.mq5 |
//|       Expert Advisor with Enhanced Modern MainPanel Class        |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#include <Controls\Defines.mqh>
#include <Object.mqh>
#include <StandardGUI\EventData.mqh>
#include <StandardGUI\CustomCheckbox.mqh> 

// Redefine UI Colors with a Modern Palette
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_BORDER_DARK
#undef CONTROLS_DIALOG_COLOR_BORDER_LIGHT
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
#undef CONTROLS_DIALOG_COLOR_CLIENT_BORDER

#define CONTROLS_DIALOG_COLOR_CLIENT_BG     C'24,24,24'    // Slightly lighter dark background
#define CONTROLS_DIALOG_COLOR_BORDER_DARK   C'70,70,70'    // Modern dark border
#define CONTROLS_DIALOG_COLOR_BORDER_LIGHT  C'90,90,90'    // Modern light border
#define CONTROLS_DIALOG_COLOR_BG            C'30,30,30'    // Modern mid-tone background
#define TEXT_FONT                           "Trebuchet MS"     // Modern font
#define ACCENT_COLOR                        C'33,150,243'  // Blue accent
#define SECONDARY_COLOR                     C'76,175,80'   // Green secondary
#define TEXT_COLOR                          C'255,255,255' // White text
#define CONTROLS_DIALOG_COLOR_CAPTION_TEXT  C'255,255,255' // White caption text
#define GRAY_COLOR_LIGHT                    C'189,189,189' // Light Gray for disabled buttons
#define GRAY_COLOR_DARK                     C'121,121,121' // Dark Gray for selected risk button
#define CONTROLS_DIALOG_COLOR_CLIENT_BORDER C'24,24,24'    // Same as client_bg to avoid lines

#include <Controls\Dialog.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>
#include <Trade\Trade.mqh>
#include "TradeSelector.mqh" // Include the ListSelector class

//+------------------------------------------------------------------+
//| MainPanel Class Definition                                       |
//+------------------------------------------------------------------+
class MainPanel
{
private:
    // UI Colors and Fonts
    color            clientBgColor;
    color            borderDarkColor;
    color            borderLightColor;
    color            bgColor;
    color            captionTextColor;
    color            clientBorderColor;
    color            textColor;
    color            accentColor;
    color            secondaryColor;
    color            grayColorLight;
    color            grayColorDark;
    
    string           fontFamily;
    
    // Dimensions and Positioning
    int              dialogWidth;
    int              dialogHeight;
    int              dialogPosX;
    int              dialogPosY;
    
    bool             isTradeSelectorOpen;
    
    // Dialog and Controls
    CAppDialog       appDialog;
    
    CLabel          *titleLabel;
    CLabel          *symbolLabel;
    CEdit           *symbolEdit;
    CLabel          *volumeLabel;
    CEdit           *volumeEdit;
    
    // Stop Orders Controls
    CLabel          *stopPriceLabel;
    CEdit           *stopPriceEdit;
    CButton         *stopBuyButton;
    CButton         *stopSellButton;
    
    CButton         *buyButton;
    CButton         *sellButton;

    // Show Trades Button
    CButton         *showTradesButton;
    
    // Trade List Selector
    CTradeSelector   *tradeListSelector;
    
    // Scaling Factors
    double           scaleFactor;
    int              baseFontSize;
    
    // UI Creation Methods
    bool             CreateLabelControl(CLabel *&label, const string name, const int x, const int y, const string text, const color lblTextColor=TEXT_COLOR, const int fontSize=10);
    bool             CreateButtonControl(CButton *&button, const string name, const int x1, const int y1, const int x2, const int y2, const string text, const color btnBgColor, const color btnBorderColor, const color btnTextColor=TEXT_COLOR, const int fontSize=10, const string tooltip="");
    bool             CreateEditControl(CEdit *&edit, const string name, const int x1, const int y1, const int x2, const int y2, const string text);
    
    // Initialization Methods
    void             InitializeScaling();
    int              GetScaledFontSize(int size);
    bool             InitializeUIComponents();
    bool             ToggleTradeSelector();
    void             PopulateTradeList();
    static void      OnTradeSelectedCallback(int index, const string &columns[]);
    
public:
                        MainPanel();
                       ~MainPanel();
        
    bool            Initialize();
    void            HandleChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam);
    void            Deinitialize(const int reason);
    void            Close();
};

//+------------------------------------------------------------------+
//| MainPanel Class Implementation                                   |
//+------------------------------------------------------------------+
MainPanel::MainPanel()
{
    // Initialize UI Colors
    clientBgColor      = CONTROLS_DIALOG_COLOR_CLIENT_BG;
    borderDarkColor    = CONTROLS_DIALOG_COLOR_BORDER_DARK;
    borderLightColor   = CONTROLS_DIALOG_COLOR_BORDER_LIGHT;
    bgColor            = CONTROLS_DIALOG_COLOR_BG;
    captionTextColor   = CONTROLS_DIALOG_COLOR_CAPTION_TEXT;
    clientBorderColor  = CONTROLS_DIALOG_COLOR_CLIENT_BORDER;
    textColor          = TEXT_COLOR;
    accentColor        = ACCENT_COLOR;
    secondaryColor     = SECONDARY_COLOR;
    grayColorLight     = GRAY_COLOR_LIGHT;
    grayColorDark      = GRAY_COLOR_DARK;
    
    // Font
    fontFamily         = TEXT_FONT;
    
    // Initial State
    isTradeSelectorOpen = false;
    
    // Dimensions
    dialogWidth        = 400;
    dialogHeight       = 550;
    dialogPosX         = 50;
    dialogPosY         = 50;
    
    // Initialize pointers to NULL
    titleLabel          = NULL;
    symbolLabel         = NULL;
    symbolEdit          = NULL;
    volumeLabel         = NULL;
    volumeEdit          = NULL;
    stopPriceLabel      = NULL;
    stopPriceEdit       = NULL;
    stopBuyButton       = NULL;
    stopSellButton      = NULL;
    buyButton           = NULL;
    sellButton          = NULL;
    showTradesButton    = NULL;
    tradeListSelector   = NULL;
    
    InitializeScaling();
}

MainPanel::~MainPanel()
{
    // Destructor code if needed
}

// Initialize Scaling Factors based on DPI
void MainPanel::InitializeScaling()
{
    int dpi           = TerminalInfoInteger(TERMINAL_SCREEN_DPI);
    scaleFactor       = dpi / 96.0; 
    baseFontSize     = (int)(10 * scaleFactor);
}

// Get Scaled Font Size
int MainPanel::GetScaledFontSize(int size)
{
    return (int)(size * scaleFactor);
}

// Initialize the Main Panel UI
bool MainPanel::Initialize()
{
    // Create the main dialog
    if (!appDialog.Create(0, "Trading Panel", 0, dialogPosX, dialogPosY, dialogWidth, dialogHeight))
        return false;

    // Initialize UI Components
    if (!InitializeUIComponents())
        return false;

    // Run the dialog (handles events internally)
    if (!appDialog.Run())
        return false;

    return true;
}

// Create Label Control
bool MainPanel::CreateLabelControl(CLabel *&label, const string name, const int x, const int y, const string text, const color lblTextColor, const int fontSize)
{
    label = new CLabel();
    if(!label.Create(0, name, 0, x, y, x+200, y+fontSize*2))
    {
        delete label;
        label = NULL;
        return false;
    }
    
    label.Text(text);
    label.Color(lblTextColor);
    label.FontSize(GetScaledFontSize(fontSize));
    label.Font(fontFamily);
    // Removed Anchor method as it's undefined
    
    if(!appDialog.Add(label))
    {
        delete label;
        label = NULL;
        return false;
    }
    
    return true;
}

// Create Button Control with Customization
bool MainPanel::CreateButtonControl(CButton *&button, const string name, const int x1, const int y1, const int x2, const int y2, const string text, const color btnBgColor, const color btnBorderColor, const color btnTextColor, const int fontSize, const string tooltip)
{
    button = new CButton();
    if(!button.Create(0, name, 0, x1, y1, x2, y2))
    {
        delete button;
        button = NULL;
        return false;
    }
    button.Text(text);
    button.ColorBackground(btnBgColor);
    button.ColorBorder(btnBorderColor);
    button.Color(btnTextColor);
    button.Font(fontFamily);
    button.FontSize(GetScaledFontSize(fontSize));
    // Removed Tooltip method as it's undefined
    
    if(!appDialog.Add(button))
    {
        delete button;
        button = NULL;
        return false;
    }
    return true;
}

// Create Edit Control
bool MainPanel::CreateEditControl(CEdit *&edit, const string name, const int x1, const int y1, const int x2, const int y2, const string text)
{
    edit = new CEdit();
    if(!edit.Create(0, name, 0, x1, y1, x2, y2))
    {
        delete edit;
        edit = NULL;
        return false;
    }
    edit.Text(text);
    edit.Font(fontFamily);
    edit.FontSize(GetScaledFontSize(10));
    edit.ColorBackground(bgColor);
    edit.ColorBorder(secondaryColor);
    edit.Color(textColor);
    // Removed Anchor method as it's undefined
    
    if(!appDialog.Add(edit))
    {
        delete edit;
        edit = NULL;
        return false;
    }
    return true;
}

// Initialize UI Components
bool MainPanel::InitializeUIComponents()
{
    // Title Label
    if (!CreateLabelControl(titleLabel, "TitleLabel", 80, 10, "Trading Panel", textColor, 14))
        return false;

    // Symbol Label and Edit
    if (!CreateLabelControl(symbolLabel, "SymbolLabel", 20, 60, "Symbol:", textColor, 12))
        return false;

    if (!CreateEditControl(symbolEdit, "SymbolEdit", 150, 60, 310, 90, _Symbol))
        return false;
    symbolEdit.ReadOnly(true);

    // Volume Label and Edit
    if (!CreateLabelControl(volumeLabel, "VolumeLabel", 20, 100, "Volume:", textColor, 12))
        return false;

    if (!CreateEditControl(volumeEdit, "VolumeEdit", 150, 100, 310, 130, "0.1"))
        return false;

    // Stop Price Label and Edit
    if (!CreateLabelControl(stopPriceLabel, "StopPriceLabel", 20, 140, "Stop Price:", textColor, 12))
        return false;

    if (!CreateEditControl(stopPriceEdit, "StopPriceEdit", 150, 140, 310, 170, ""))
        return false;

    // Stop Buy Button
    if (!CreateButtonControl(stopBuyButton, "StopBuyButton", 10, 180, 160, 220, "⏫ Stop Buy", C'33,150,243', C'25,118,210', textColor, 12, "Place a Stop Buy Order"))
        return false;

    // Stop Sell Button
    if (!CreateButtonControl(stopSellButton, "StopSellButton", 180, 180, 330, 220, "⏬ Stop Sell", C'76,175,80', C'56,142,60', textColor, 12, "Place a Stop Sell Order"))
        return false;

    // Buy Button
    if (!CreateButtonControl(buyButton, "BuyButton", 10, 230, 160, 270, "🟢 Buy", C'0,150,136', C'0,121,107', textColor, 12, "Place a Buy Order"))
        return false;

    // Sell Button
    if (!CreateButtonControl(sellButton, "SellButton", 180, 230, 330, 270, "🔴 Sell", C'255,87,34', C'214,69,0', textColor, 12, "Place a Sell Order"))
        return false;

    // Show Trades Button
    if (!CreateButtonControl(showTradesButton, "ShowTradesButton", 10, 300, 330, 340, "📊 Show Trades", accentColor, secondaryColor, textColor, 12, "Toggle Trade List"))
        return false;

    // Initialize Trade List Selector (not created yet)
    tradeListSelector = NULL;

    return true;
}

// Toggle Trade Selector Visibility
bool MainPanel::ToggleTradeSelector()
{
    if(isTradeSelectorOpen){
        if(tradeListSelector != NULL){
            tradeListSelector.Destroy();
            delete tradeListSelector;
            tradeListSelector = NULL;
        }
        showTradesButton.Text("📊 Show Trades");
        isTradeSelectorOpen = false;
        return true;
    }    

    // Define headers and column widths for trades
    string headers[] = {"Ticket", "Symbol", "Type", "Volume", "Price", "Profit"};
    int columnWidths[] = {120, 100, 80, 80, 100, 80};
    int numColumns = ArraySize(headers);
    int listWidth = 0;
    for(int i = 0; i < numColumns; i++) listWidth += columnWidths[i];

    // Create a TradeSelector instance
    tradeListSelector = new CTradeSelector();
    
    // Define the dimensions for the list selector
    int listPosX = appDialog.Right();
    int listPosY = appDialog.Bottom()-180;
    int listWidthFinal = listWidth + 20;
    int listHeight = 165;
    
    bool created = tradeListSelector.Create(
        0,
        "TradeList",
        0, // Subwindow
        listPosX,
        listPosY,
        listPosX + listWidthFinal,
        listPosY + listHeight,
        headers,
        columnWidths,
        numColumns
    );
    
    if(!created)
    {
        Print("Failed to create TradeList.");
        return false;
    }
    
    // Define callback for item selection
    tradeListSelector.SetCallback(OnTradeSelectedCallback);
    isTradeSelectorOpen = true;
    showTradesButton.Text("❌ Close Trades");
    return true;
}

// Populate Trade List with Open Positions
void MainPanel::PopulateTradeList()
{
    if(tradeListSelector == NULL)
        return;

    // Clear existing items
    tradeListSelector.ClearItems();

    // Iterate through all open positions
    for(int i = 0; i < PositionsTotal(); i++)
    {
        ulong ticket = PositionGetTicket(i);
        if(!PositionSelectByTicket(ticket))
            continue;
        
        string symbol = PositionGetString(POSITION_SYMBOL);
        int typeInt = PositionGetInteger(POSITION_TYPE);
        string type = (typeInt == POSITION_TYPE_BUY) ? "BUY" : (typeInt == POSITION_TYPE_SELL) ? "SELL" : "UNKNOWN";

        double volume = PositionGetDouble(POSITION_VOLUME);
        double price = PositionGetDouble(POSITION_PRICE_OPEN);
        double profit = PositionGetDouble(POSITION_PROFIT);
        
        string itemColumns[];
        ArrayResize(itemColumns, 6);
        itemColumns[0] = ticket; // Changed from IntegerToString to LongToString
        itemColumns[1] = symbol;
        itemColumns[2] = type;
        itemColumns[3] = DoubleToString(volume, 2);
        itemColumns[4] = DoubleToString(price, _Digits);
        itemColumns[5] = DoubleToString(profit, 2);
        
        tradeListSelector.AddItem(itemColumns);
    }
}

// Callback Function when a Trade is Selected
void MainPanel::OnTradeSelectedCallback(int index, const string &columns[])
{
    // Example: Display selected trade details in the Experts log
    string message = StringFormat("Trade Selected - Ticket: %s, Symbol: %s, Type: %s, Volume: %s, Price: %s, Profit: %s", 
                                   columns[0], columns[1], columns[2], columns[3], columns[4], columns[5]);
    Print(message);
    
    // Additional actions can be implemented here
}

// Handle Chart Events and UI Interactions
void MainPanel::HandleChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    appDialog.ChartEvent(id, lparam, dparam, sparam);

    if(isTradeSelectorOpen && tradeListSelector != NULL)
        tradeListSelector.HandleEvent(id, lparam, dparam, sparam);

    if(id == CHARTEVENT_OBJECT_CLICK)
    {
        string objName = sparam;
        if(objName == "BuyButton")
        {
            // Retrieve Volume
            double volume = StringToDouble(volumeEdit.Text());
            if(volume <= 0)
            {
                Alert("⚠️ Please enter a valid volume.");
                return;
            }

            // Place Buy Order
            CTrade trade;
            trade.SetExpertMagicNumber(123456); // Optional Magic Number
            if(trade.Buy(volume, _Symbol))
            {
                Alert("✅ Buy order placed successfully.");
            }
            else
            {
                Alert("❌ Failed to place Buy order: " + trade.ResultComment());
            }
        }
        else if(objName == "SellButton")
        {
            // Retrieve Volume
            double volume = StringToDouble(volumeEdit.Text());
            if(volume <= 0)
            {
                Alert("⚠️ Please enter a valid volume.");
                return;
            }

            // Place Sell Order
            CTrade trade;
            trade.SetExpertMagicNumber(123456); // Optional Magic Number
            if(trade.Sell(volume, _Symbol))
            {
                Alert("✅ Sell order placed successfully.");
            }
            else
            {
                Alert("❌ Failed to place Sell order: " + trade.ResultComment());
            }
        }
        else if(objName == "StopBuyButton")
        {
            // Retrieve Volume and Stop Price
            double volume = StringToDouble(volumeEdit.Text());
            double stopPrice = StringToDouble(stopPriceEdit.Text());
            if(volume <= 0 || stopPrice <= 0)
            {
                Alert("⚠️ Please enter valid volume and stop price.");
                return;
            }

            // Place Stop Buy Order
            CTrade trade;
            trade.SetExpertMagicNumber(123456); // Optional Magic Number
            if(trade.BuyStop(volume, stopPrice, _Symbol))
            {
                Alert("✅ Stop Buy order placed at price: " + DoubleToString(stopPrice, _Digits));
            }
            else
            {
                Alert("❌ Failed to place Stop Buy order: " + trade.ResultComment());
            }
        }
        else if(objName == "StopSellButton")
        {
            // Retrieve Volume and Stop Price
            double volume = StringToDouble(volumeEdit.Text());
            double stopPrice = StringToDouble(stopPriceEdit.Text());
            if(volume <= 0 || stopPrice <= 0)
            {
                Alert("⚠️ Please enter valid volume and stop price.");
                return;
            }

            // Place Stop Sell Order
            CTrade trade;
            trade.SetExpertMagicNumber(123456); // Optional Magic Number
            if(trade.SellStop(volume, stopPrice, _Symbol))
            {
                Alert("✅ Stop Sell order placed at price: " + DoubleToString(stopPrice, _Digits));
            }
            else
            {
                Alert("❌ Failed to place Stop Sell order: " + trade.ResultComment());
            }
        }
        else if(objName == "ShowTradesButton")
        {
            // Toggle Trade List Visibility
            if(ToggleTradeSelector())
            {
                // Populate the Trade List if opened
                if(isTradeSelectorOpen)
                    PopulateTradeList();
            }
            else
            {
                Alert("❌ Failed to toggle Trade List.");
            }
        }
    }
}

// Deinitialize the Main Panel
void MainPanel::Deinitialize(const int reason)
{
    if(tradeListSelector != NULL)
    {
        tradeListSelector.Destroy();
        delete tradeListSelector;
        tradeListSelector = NULL;
    }
    appDialog.Destroy(reason);
}

// Close the Main Panel
void MainPanel::Close()
{
    Print("Closing Modern Trading Panel: ", appDialog.Name());
    Deinitialize(REASON_REMOVE);
}

