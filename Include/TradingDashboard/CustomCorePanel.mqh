//+------------------------------------------------------------------+
//|                                                Panel.mqh         |
//|                     Core Panel Design Class for MQL5 Applications |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#include <Controls\Defines.mqh>
#include <Object.mqh>

#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_BORDER_DARK
#undef CONTROLS_DIALOG_COLOR_BORDER_LIGHT
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
#undef CONTROLS_DIALOG_COLOR_CLIENT_BORDER

#define CONTROLS_DIALOG_COLOR_CLIENT_BG     C'28,32,38'  //deep blue-grey background
#define CONTROLS_DIALOG_COLOR_BORDER_DARK   C'58,62,70'  //darker border
#define CONTROLS_DIALOG_COLOR_BORDER_LIGHT  C'76,86,106' //lighter border
#define CONTROLS_DIALOG_COLOR_BG            C'47,54,65'  //mid-tone background
#define TEXT_FONT                           "Trebuchet MS"
#define ACCENT_COLOR                        C'86,182,194' //soft teal
#define SECONDARY_COLOR                     C'255,171,145' //coral
#define TEXT_COLOR                          C'236,239,244' //soft white
#define CONTROLS_DIALOG_COLOR_CAPTION_TEXT  C'236,239,244' //soft white
#define GRAY_COLOR_LIGHT                    C'188,194,205' //warmer light gray
#define GRAY_COLOR_DARK                     C'130,140,153' //warmer dark gray
#define CONTROLS_DIALOG_COLOR_CLIENT_BORDER C'28,32,38'  //matches client_bg

#include <Controls\Dialog.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>

#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| Panel Class                                            |
//+------------------------------------------------------------------+
class Panel : public CObject
{
protected:
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
   
   // Scaling factor for font sizes
   double           m_scale_factor;
   
   // Base font size
   int              m_base_font_size;
   
   // Methods
   void             InitializeScaling();
   int              ScaledFontSize(int size);
   
public:
                    Panel();
                   ~Panel();
   
   bool             Initialize();
   virtual void     HandleChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam);
   void             Deinitialize(const int reason);
   void             Close();
   // Methods to create controls with standard design
   bool             CreateLabel(const string name, const int x, const int y, const string text, const color textColor=TEXT_COLOR, const int fontSize=8);
   bool             CreateButton(const string name, const int x1, const int y1, const int x2, const int y2, const string text);
   bool             CreateEdit(const string name, const int x1, const int y1, const int x2, const int y2, const string text);
   
   // Virtual method to initialize components
   virtual bool     InitializeComponents() { return true; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
Panel::Panel()
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
   m_dialog_height        = 480;
   m_dialog_x             = 20;
   m_dialog_y             = 20;
   
   InitializeScaling();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
Panel::~Panel()
{
   // Destructor code (if needed)
}

//+------------------------------------------------------------------+
//| Initialize Scaling                                               |
//+------------------------------------------------------------------+
void Panel::InitializeScaling()
{
   int dpi           = TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   m_scale_factor    = dpi / 96.0; 
   m_base_font_size  = (int)(10 * m_scale_factor);
}

//+------------------------------------------------------------------+
//| Scaled Font Size                                                 |
//+------------------------------------------------------------------+
int Panel::ScaledFontSize(int size)
{
   return (int)(size * m_scale_factor);
}

//+------------------------------------------------------------------+
//| Create Panel                                                     |
//+------------------------------------------------------------------+
bool Panel::Initialize()
{
    if (!m_app_dialog.Create(0, "Trading Dashboard", 0, m_dialog_x, m_dialog_y, m_dialog_width, m_dialog_height))
        return false;

    // Initialize components
    if (!InitializeComponents())
        return false;

    // Do not call m_app_dialog.Run();
    // The main event loop in OnChartEvent will handle events

    return true;
}

//+------------------------------------------------------------------+
//| Create Label                                                     |
//+------------------------------------------------------------------+
bool Panel::CreateLabel(const string name, const int x, const int y, const string text, const color textColor, const int fontSize)
{
   CLabel *label = new CLabel();
   if(!label.Create(0, name, 0, x, y, 0, 0))
      return false;
   
   if(!label.Text(text))
      return false;
   
   if(!label.Color(textColor))
      return false;
   
   if(!label.FontSize(ScaledFontSize(fontSize)))
      return false;
   
   if(!label.Font(m_text_font))
      return false;

   if(!m_app_dialog.Add(label))
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Create Button                                                    |
//+------------------------------------------------------------------+
bool Panel::CreateButton(const string name, const int x1, const int y1, const int x2, const int y2, const string text)
{
   CButton *button = new CButton();
   if(!button.Create(0, name, 0, x1, y1, x2, y2))
      return false;
   if(!button.Text(text))
      return false;
   if(!button.ColorBackground(m_accent_color))
      return false;
   if(!button.ColorBorder(m_secondary_color))
      return false;
   if(!button.Font(m_text_font))
      return false;
   if(!button.FontSize(ScaledFontSize(9)))
      return false;
   if(!m_app_dialog.Add(button))
      return false;
   return true;
}

//+------------------------------------------------------------------+
//| Create Edit Control                                              |
//+------------------------------------------------------------------+
bool Panel::CreateEdit(const string name, const int x1, const int y1, const int x2, const int y2, const string text)
{
   CEdit *edit = new CEdit();
   if(!edit.Create(0, name, 0, x1, y1, x2, y2))
      return false;
   if(!edit.Text(text))
      return false;
   if(!edit.Font(m_text_font))
      return false;
   if(!edit.FontSize(ScaledFontSize(10)))
      return false;
   if(!edit.ColorBackground(CONTROLS_DIALOG_COLOR_BG))
      return false;
   if(!edit.ColorBorder(m_secondary_color))
      return false;
   if(!edit.Color(m_text_color))
      return false;
   if(!m_app_dialog.Add(edit))
      return false;
   return true;
}

void Panel::Deinitialize(const int reason)
{
  m_app_dialog.Destroy(reason);
}

void Panel::Close()
{
       Print("Closing panel: ", m_app_dialog.Name());
    Deinitialize(REASON_REMOVE);
}

void Panel::HandleChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   m_app_dialog.ChartEvent(id, lparam, dparam, sparam);
}
