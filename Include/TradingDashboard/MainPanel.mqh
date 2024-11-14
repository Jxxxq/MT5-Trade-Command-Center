//+------------------------------------------------------------------+
//|                                             MainPanelEA.mq5       |
//|       Expert Advisor with Integrated MainPanel Class              |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#include <Controls\Defines.mqh>
#include <Object.mqh>
#include <StandardGUI\EventData.mqh>
#include <StandardGUI\CustomCheckbox.mqh> 

#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_BORDER_DARK
#undef CONTROLS_DIALOG_COLOR_BORDER_LIGHT
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
#undef CONTROLS_DIALOG_COLOR_CLIENT_BORDER

#define CONTROLS_DIALOG_COLOR_CLIENT_BG     C'18,18,18'  //dark background
#define CONTROLS_DIALOG_COLOR_BORDER_DARK   C'50,50,50'  //slightly lighter border
#define CONTROLS_DIALOG_COLOR_BORDER_LIGHT  C'60,60,60'  //even lighter border
#define CONTROLS_DIALOG_COLOR_BG            C'45,45,45'  //mid-tone background
#define TEXT_FONT                           "Trebuchet MS"
#define ACCENT_COLOR                        C'0,150,136' //teal
#define SECONDARY_COLOR                     C'96,125,139' //blue grey
#define TEXT_COLOR                          C'255,255,255' //white
#define CONTROLS_DIALOG_COLOR_CAPTION_TEXT  C'255,255,255' //white
#define GRAY_COLOR_LIGHT                    C'160,160,160' // Light Gray for general disabled buttons
#define GRAY_COLOR_DARK                     C'110,110,110' // Dark Gray for the selected risk button
#define CONTROLS_DIALOG_COLOR_CLIENT_BORDER C'18,18,18'  //same as client_bg bc otherwise it creates a thin white line between bg and client_bg

#include <Controls\Dialog.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| MainPanel Class Definition                                       |
//+------------------------------------------------------------------+
class MainPanel
{
private:
    // Colors and fonts
    color            m_client_bg_color;
    color            m_border_dark_color;
    color            m_border_light_color;
    color            m_bg_color;
    color            m_caption_text_color;
    color            m_client_border_color;
    color            m_text_color;
    color            m_accent_color;
    color            m_secondary_color;
    color            m_gray_color_light;
    color            m_gray_color_dark;
    
    string           m_text_font;
    
    // Dimensions
    int              m_dialog_width;
    int              m_dialog_height;
    int              m_dialog_x;
    int              m_dialog_y;
    
    // App dialog
    CAppDialog       m_app_dialog;
    
    // Controls
    CLabel          *m_title_label;
    CLabel          *m_symbol_label;
    CEdit           *m_symbol_edit;
    CLabel          *m_volume_label;
    CEdit           *m_volume_edit;
    
    // *** New Controls for Stop Orders ***
    CLabel          *m_stop_price_label;
    CEdit           *m_stop_price_edit;
    CButton         *m_stop_buy_button;
    CButton         *m_stop_sell_button;
    
    CButton         *m_buy_button;
    CButton         *m_sell_button;
    
    // Scaling factor for font sizes
    double           m_scale_factor;
    
    // Base font size
    int              m_base_font_size;
    
    // Methods
    void             InitializeScaling();
    int              ScaledFontSize(int size);
    
    // Create Controls
    bool             CreateLabel(CLabel *&label, const string name, const int x, const int y, const string text, const color textColor=TEXT_COLOR, const int fontSize=8);
    bool             CreateButton(CButton *&button, const string name, const int x1, const int y1, const int x2, const int y2, const string text);
    bool             CreateEdit(CEdit *&edit, const string name, const int x1, const int y1, const int x2, const int y2, const string text);
    
    // Initialize Components
    bool             InitializeComponents();
    
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
    // Initialize colors
    m_client_bg_color      = CONTROLS_DIALOG_COLOR_CLIENT_BG;
    m_border_dark_color    = CONTROLS_DIALOG_COLOR_BORDER_DARK;
    m_border_light_color   = CONTROLS_DIALOG_COLOR_BORDER_LIGHT;
    m_bg_color             = CONTROLS_DIALOG_COLOR_BG;
    m_caption_text_color   = TEXT_COLOR;
    m_client_border_color  = CONTROLS_DIALOG_COLOR_CLIENT_BG;
    m_text_color           = TEXT_COLOR;
    m_accent_color         = ACCENT_COLOR;
    m_secondary_color      = SECONDARY_COLOR;
    m_gray_color_light     = GRAY_COLOR_LIGHT;
    m_gray_color_dark      = GRAY_COLOR_DARK;
    
    // Font
    m_text_font            = TEXT_FONT;
    
    // Dimensions
    m_dialog_width         = 360;
    m_dialog_height        = 500;
    m_dialog_x             = 20;
    m_dialog_y             = 20;
    
    // Initialize pointers to NULL
    m_title_label          = NULL;
    m_symbol_label         = NULL;
    m_symbol_edit          = NULL;
    m_volume_label         = NULL;
    m_volume_edit          = NULL;
    m_stop_price_label     = NULL;
    m_stop_price_edit      = NULL;
    m_stop_buy_button      = NULL;
    m_stop_sell_button     = NULL;
    m_buy_button           = NULL;
    m_sell_button          = NULL;
    
    InitializeScaling();
}

MainPanel::~MainPanel()
{
    // Destructor code (if needed)
}

// Initialize Scaling
void MainPanel::InitializeScaling()
{
    int dpi           = TerminalInfoInteger(TERMINAL_SCREEN_DPI);
    m_scale_factor    = dpi / 96.0; 
    m_base_font_size  = (int)(10 * m_scale_factor);
}

// Scaled Font Size
int MainPanel::ScaledFontSize(int size)
{
    return (int)(size * m_scale_factor);
}

// Initialize Panel
bool MainPanel::Initialize()
{
    if (!m_app_dialog.Create(0, "Trading Panel", 0, m_dialog_x, m_dialog_y, m_dialog_width, m_dialog_height))
        return false;

    // Initialize components
    if (!InitializeComponents())
        return false;

    // Run the dialog (this will handle events internally)
    if (!m_app_dialog.Run())
        return false;

    return true;
}

// Create Label
bool MainPanel::CreateLabel(CLabel *&label, const string name, const int x, const int y, const string text, const color textColor, const int fontSize)
{
   label = new CLabel();
   if(!label.Create(0, name, 0, x, y, x+200, y+20))
   {
       delete label;
       label = NULL;
       return false;
   }
   
   label.Text(text);
   label.Color(textColor);
   label.FontSize(ScaledFontSize(fontSize));
   label.Font(m_text_font);

   if(!m_app_dialog.Add(label))
   {
       delete label;
       label = NULL;
       return false;
   }
   
   return true;
}

// Create Button
bool MainPanel::CreateButton(CButton *&button, const string name, const int x1, const int y1, const int x2, const int y2, const string text)
{
   button = new CButton();
   if(!button.Create(0, name, 0, x1, y1, x2, y2))
   {
       delete button;
       button = NULL;
       return false;
   }
   button.Text(text);
   button.ColorBackground(m_accent_color);
   button.ColorBorder(m_secondary_color);
   button.Font(m_text_font);
   button.FontSize(ScaledFontSize(10));
   if(!m_app_dialog.Add(button))
   {
       delete button;
       button = NULL;
       return false;
   }
   return true;
}

// Create Edit Control
bool MainPanel::CreateEdit(CEdit *&edit, const string name, const int x1, const int y1, const int x2, const int y2, const string text)
{
   edit = new CEdit();
   if(!edit.Create(0, name, 0, x1, y1, x2, y2))
   {
       delete edit;
       edit = NULL;
       return false;
   }
   edit.Text(text);
   edit.Font(m_text_font);
   edit.FontSize(ScaledFontSize(10));
   edit.ColorBackground(CONTROLS_DIALOG_COLOR_BG);
   edit.ColorBorder(m_secondary_color);
   edit.Color(m_text_color);
   if(!m_app_dialog.Add(edit))
   {
       delete edit;
       edit = NULL;
       return false;
   }
   return true;
}

// Initialize Components
bool MainPanel::InitializeComponents()
{
    if (!CreateLabel(m_title_label, "TitleLabel", 20, 20, "Trading Panel", TEXT_COLOR, 14))
        return false;

    if (!CreateLabel(m_symbol_label, "SymbolLabel", 20, 60, "Symbol:", TEXT_COLOR, 10))
        return false;

    if (!CreateEdit(m_symbol_edit, "SymbolEdit", 100, 60, 300, 90, _Symbol))
        return false;
    m_symbol_edit.ReadOnly(true);

    if (!CreateLabel(m_volume_label, "VolumeLabel", 20, 100, "Volume:", TEXT_COLOR, 10))
        return false;

    if (!CreateEdit(m_volume_edit, "VolumeEdit", 100, 100, 300, 130, "0.1"))
        return false;

    // *** New Controls for Stop Orders ***
    if (!CreateLabel(m_stop_price_label, "StopPriceLabel", 20, 140, "Stop Price:", TEXT_COLOR, 10))
        return false;

    if (!CreateEdit(m_stop_price_edit, "StopPriceEdit", 100, 140, 300, 170, ""))
        return false;

    if (!CreateButton(m_stop_buy_button, "StopBuyButton", 20, 180, 155, 210, "Stop Buy"))
        return false;

    if (!CreateButton(m_stop_sell_button, "StopSellButton", 180, 180, 315, 210, "Stop Sell"))
        return false;

    // Existing Buy and Sell Buttons
    if (!CreateButton(m_buy_button, "BuyButton", 20, 230, 155, 260, "Buy"))
        return false;

    if (!CreateButton(m_sell_button, "SellButton", 180, 230, 315, 260, "Sell"))
        return false;

    // Customize Buy Button
    m_buy_button.ColorBackground(C'0,153,0'); // Green
    m_buy_button.ColorBorder(C'0,102,0');     // Darker Green
    m_buy_button.Color(TEXT_COLOR);
    m_buy_button.FontSize(ScaledFontSize(10));

    // Customize Sell Button
    m_sell_button.ColorBackground(C'204,0,0'); // Red
    m_sell_button.ColorBorder(C'153,0,0');     // Darker Red
    m_sell_button.Color(TEXT_COLOR);
    m_sell_button.FontSize(ScaledFontSize(10));

    // Customize Stop Buy Button
    m_stop_buy_button.ColorBackground(C'0,102,204'); // Blue
    m_stop_buy_button.ColorBorder(C'0,76,153');     // Darker Blue
    m_stop_buy_button.Color(TEXT_COLOR);
    m_stop_buy_button.FontSize(ScaledFontSize(10));

    // Customize Stop Sell Button
    m_stop_sell_button.ColorBackground(C'153,0,153'); // Purple
    m_stop_sell_button.ColorBorder(C'102,0,102');     // Darker Purple
    m_stop_sell_button.Color(TEXT_COLOR);
    m_stop_sell_button.FontSize(ScaledFontSize(10));

    return true;
}

// Handle Chart Event
void MainPanel::HandleChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    m_app_dialog.ChartEvent(id, lparam, dparam, sparam);

    if(id == CHARTEVENT_OBJECT_CLICK)
    {
        string name = sparam;
        if(name == "BuyButton")
        {
            // Get the volume from VolumeEdit
            double volume = 0.0;
            if(m_volume_edit != NULL)
            {
                string volumeStr = m_volume_edit.Text();
                volume = StringToDouble(volumeStr);
            }
            if(volume <= 0)
            {
                Alert("Error: Please enter a valid volume.");
                return;
            }

            // Place Buy Order
            CTrade trade;
            trade.SetAsyncMode(false);
            trade.SetExpertMagicNumber(123456); // Optional: Set a magic number
            if(trade.Buy(volume, _Symbol))
            {
                Alert("Buy order placed successfully.");
            }
            else
            {
                string errorDescription = trade.ResultComment();
                Alert("Failed to place Buy order: " + errorDescription);
            }
        }
        else if(name == "SellButton")
        {
            // Get the volume from VolumeEdit
            double volume = 0.0;
            if(m_volume_edit != NULL)
            {
                string volumeStr = m_volume_edit.Text();
                volume = StringToDouble(volumeStr);
            }
            if(volume <= 0)
            {
                Alert("Error: Please enter a valid volume.");
                return;
            }

            // Place Sell Order
            CTrade trade;
            trade.SetAsyncMode(false);
            trade.SetExpertMagicNumber(123456); // Optional: Set a magic number
            if(trade.Sell(volume, _Symbol))
            {
                Alert("Sell order placed successfully.");
            }
            else
            {
                string errorDescription = trade.ResultComment();
                Alert("Failed to place Sell order: " + errorDescription);
            }
        }
        // *** Handling Stop Buy and Stop Sell Buttons ***
        else if(name == "StopBuyButton")
        {
            // Get the volume from VolumeEdit
            double volume = 0.0;
            if(m_volume_edit != NULL)
            {
                string volumeStr = m_volume_edit.Text();
                volume = StringToDouble(volumeStr);
            }
            if(volume <= 0)
            {
                Alert("Error: Please enter a valid volume.");
                return;
            }

            // Get the stop price from StopPriceEdit
            double stopPrice = 0.0;
            if(m_stop_price_edit != NULL)
            {
                string stopPriceStr = m_stop_price_edit.Text();
                stopPrice = StringToDouble(stopPriceStr);
            }
            if(stopPrice <= 0)
            {
                Alert("Error: Please enter a valid stop price.");
                return;
            }

            // Place Stop Buy Order
            CTrade trade;
            trade.SetAsyncMode(false);
            trade.SetExpertMagicNumber(123456); // Optional: Set a magic number
            if(trade.BuyStop(volume, stopPrice, _Symbol))
            {
                Alert("Stop Buy order placed successfully at price: " + DoubleToString(stopPrice, _Digits));
            }
            else
            {
                string errorDescription = trade.ResultComment();
                Alert("Failed to place Stop Buy order: " + errorDescription);
            }
        }
        else if(name == "StopSellButton")
        {
            // Get the volume from VolumeEdit
            double volume = 0.0;
            if(m_volume_edit != NULL)
            {
                string volumeStr = m_volume_edit.Text();
                volume = StringToDouble(volumeStr);
            }
            if(volume <= 0)
            {
                Alert("Error: Please enter a valid volume.");
                return;
            }

            // Get the stop price from StopPriceEdit
            double stopPrice = 0.0;
            if(m_stop_price_edit != NULL)
            {
                string stopPriceStr = m_stop_price_edit.Text();
                stopPrice = StringToDouble(stopPriceStr);
            }
            if(stopPrice <= 0)
            {
                Alert("Error: Please enter a valid stop price.");
                return;
            }

            // Place Stop Sell Order
            CTrade trade;
            trade.SetAsyncMode(false);
            trade.SetExpertMagicNumber(123456); // Optional: Set a magic number
            if(trade.SellStop(volume, stopPrice, _Symbol))
            {
                Alert("Stop Sell order placed successfully at price: " + DoubleToString(stopPrice, _Digits));
            }
            else
            {
                string errorDescription = trade.ResultComment();
                Alert("Failed to place Stop Sell order: " + errorDescription);
            }
        }
    }
}

// Deinitialize
void MainPanel::Deinitialize(const int reason)
{
    m_app_dialog.Destroy(reason);
}

// Close
void MainPanel::Close()
{
   Print("Closing panel: ", m_app_dialog.Name());
   Deinitialize(REASON_REMOVE);
}