//+------------------------------------------------------------------+
//|                                                   ListSelector.mqh|
//|                                  Copyright 2024, Your Company     |
//|                                             https://www.example.com|
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Your Company"
#property link      "https://www.example.com"

#include <ChartObjects\ChartObjectsTxtControls.mqh>

//+------------------------------------------------------------------+
//| CTradeSelector Class                                              |
//|                                                                  |
//+------------------------------------------------------------------+
class CTradeSelector
{
private:
   string            m_name;           
   long              m_chart_id;         
   int               m_subwin;           
   int               m_x1, m_y1, m_x2, m_y2; 

   struct ListItem
   {
      string columns[];
   };

   ListItem          m_items[];         
   int               m_num_columns;    

   // Display properties
   int               m_selected_index;   
   int               m_scroll_position;  
   int               m_visible_items;   
   int               m_hovered_index;    

   // Visual properties
   color             m_background_color; // Background color
   color             m_border_color;     // Border color
   color             m_text_color;       // Text color
   color             m_selected_color;   // Selected item color
   color             m_hover_color;      // Hover color
   color             m_header_color;     // Header color
   int               m_font_size;        // Font size
   string            m_font_name;        // Font name

   string            m_headers[];        // Column headers
   int               m_column_widths[];  // Column widths in pixels

   typedef void (*m_on_item_selected)(int, const string &columns[]);
   m_on_item_selected m_callback;      

public:
                        CTradeSelector();
                       ~CTradeSelector();
                       
   bool                 Create(const long chart, const string name, const int subwin, 
                                 const int x1, const int y1, const int x2, const int y2, 
                                 const string &headers[], const int &column_widths[], const int num_columns);
   void                 Destroy();
   void                 HandleEvent(const int id, const long& lparam, const double& dparam, const string& sparam);
   void                 AddItem(const string &item_columns[]);
   
   void                 SetColors(color background, color border, color text, color selected, color hover, color header);
   void                 SetFont(const string& font_name, int font_size);
   void                 SetCallback(m_on_item_selected callback) { m_callback = callback; }
   
   int                  GetSelectedIndex();
   string               GetSelectedItemColumn(int column);
   
   // *** New Public Method to Clear All Items ***
   void                 ClearItems();
   
private:
   bool                 CreateRectangle();
   void                 CreateSectionHeaders();
   void                 CreateListItems();
   void                 UpdateListDisplay();
   void                 DrawScrollbar();
   
   int                  GetClickedItemIndex(const int x, const int y);
   void                 HandleKeyPress(int key_code);
   void                 MoveSelection(int delta);
   
   void                 PrintSelectedItem();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeSelector::CTradeSelector()
  : m_chart_id(0), m_subwin(0), m_x1(0), m_y1(0), m_x2(0), m_y2(0),
    m_selected_index(-1), m_scroll_position(0), m_visible_items(0),
    m_background_color(C'18,18,18'), m_border_color(clrGray),
    m_text_color(clrWhite), m_selected_color(clrBlue),
    m_hover_color(clrLightBlue), m_header_color(clrWhite),
    m_font_size(10), m_font_name("Arial"),
    m_hovered_index(-1), m_callback(NULL), m_num_columns(0)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeSelector::~CTradeSelector()
{
   Destroy();
}

//+------------------------------------------------------------------+
//| Create the list selector object                                  |
//+------------------------------------------------------------------+
bool CTradeSelector::Create(const long chart, const string name, const int subwin, 
                           const int x1, const int y1, const int x2, const int y2, 
                           const string &headers[], const int &column_widths[], const int num_columns)
{
   if(num_columns <= 0)
   {
      Print("Number of columns must be greater than zero.");
      return false;
   }
   
   m_chart_id = chart;
   m_name = name;
   m_subwin = subwin;
   m_x1 = x1;
   m_y1 = y1;
   m_x2 = x2;
   m_y2 = y2;
   m_num_columns = num_columns;
   
   // Initialize headers and column widths
   ArrayResize(m_headers, m_num_columns);
   ArrayResize(m_column_widths, m_num_columns);
   for(int i = 0; i < m_num_columns; i++)
   {
      m_headers[i] = headers[i];
      m_column_widths[i] = column_widths[i];
   }

   if(!CreateRectangle())
      return false;
   CreateSectionHeaders();
   CreateListItems();
   DrawScrollbar();
   return true;
}

//+------------------------------------------------------------------+
//| Create the main rectangle for the list selector                  |
//+------------------------------------------------------------------+
bool CTradeSelector::CreateRectangle()
{
   if(!ObjectCreate(m_chart_id, m_name, OBJ_RECTANGLE_LABEL, m_subwin, 0, 0))
      return false;

   ObjectSetInteger(m_chart_id, m_name, OBJPROP_XDISTANCE, m_x1);
   ObjectSetInteger(m_chart_id, m_name, OBJPROP_YDISTANCE, m_y1);
   ObjectSetInteger(m_chart_id, m_name, OBJPROP_XSIZE, m_x2 - m_x1);
   ObjectSetInteger(m_chart_id, m_name, OBJPROP_YSIZE, m_y2 - m_y1);
   ObjectSetInteger(m_chart_id, m_name, OBJPROP_BGCOLOR, m_background_color);
   ObjectSetInteger(m_chart_id, m_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(m_chart_id, m_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(m_chart_id, m_name, OBJPROP_BORDER_COLOR, m_border_color);

   return true;
}

//+------------------------------------------------------------------+
//| Create section headers for the list selector                     |
//+------------------------------------------------------------------+
void CTradeSelector::CreateSectionHeaders()
{
   int header_y = m_y1 + 5;
   int current_x = m_x1 + 5;
   
   for(int i = 0; i < m_num_columns; i++)
   {
      string header_name = m_name + "Header" + IntegerToString(i);
      if(!ObjectCreate(m_chart_id, header_name, OBJ_LABEL, m_subwin, 0, 0))
      {
         Print("Failed to create header: ", header_name);
         continue;
      }
      
      ObjectSetInteger(m_chart_id, header_name, OBJPROP_XDISTANCE, current_x);
      ObjectSetInteger(m_chart_id, header_name, OBJPROP_YDISTANCE, header_y);
      ObjectSetInteger(m_chart_id, header_name, OBJPROP_COLOR, m_header_color);
      ObjectSetInteger(m_chart_id, header_name, OBJPROP_FONTSIZE, m_font_size + 2);
      ObjectSetString(m_chart_id, header_name, OBJPROP_FONT, m_font_name);
      ObjectSetString(m_chart_id, header_name, OBJPROP_TEXT, m_headers[i]);
      ObjectSetInteger(m_chart_id, header_name, OBJPROP_WIDTH, m_column_widths[i]);
      
      current_x += m_column_widths[i];
   }
}

//+------------------------------------------------------------------+
//| Create list items for the list selector                          |
//+------------------------------------------------------------------+
void CTradeSelector::CreateListItems()
{
   int item_height = (int)(m_font_size * 1.5);
   m_visible_items = (m_y2 - m_y1 - 40) / item_height; // Adjust as needed for header space
   
   for(int i = 0; i < m_visible_items; i++)
   {
      int current_x = m_x1 + 5;
      for(int j = 0; j < m_num_columns; j++)
      {
         string item_name = m_name + "Item" + IntegerToString(i) + "_" + IntegerToString(j);
         if(!ObjectCreate(m_chart_id, item_name, OBJ_LABEL, m_subwin, 0, 0))
         {
            Print("Failed to create list item: ", item_name);
            continue;
         }

         ObjectSetInteger(m_chart_id, item_name, OBJPROP_XDISTANCE, current_x);
         ObjectSetInteger(m_chart_id, item_name, OBJPROP_YDISTANCE, m_y1 + 40 + i * item_height);
         ObjectSetInteger(m_chart_id, item_name, OBJPROP_COLOR, m_text_color);
         ObjectSetInteger(m_chart_id, item_name, OBJPROP_FONTSIZE, m_font_size);
         ObjectSetString(m_chart_id, item_name, OBJPROP_FONT, m_font_name);
         
         current_x += m_column_widths[j];
      }
   }

   UpdateListDisplay();
}

//+------------------------------------------------------------------+
//| Handle events for the list selector                              |
//+------------------------------------------------------------------+
void CTradeSelector::HandleEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   if(id == CHARTEVENT_KEYDOWN)
   {
      int key_code = (int)lparam;
      HandleKeyPress(key_code);
   }
   else if(id == CHARTEVENT_CLICK)
   {
      int x = (int)lparam;
      int y = (int)dparam;
      int clicked_index = GetClickedItemIndex(x, y);
      if(clicked_index != -1)
      {
         m_selected_index = clicked_index + m_scroll_position;
         UpdateListDisplay();
         PrintSelectedItem();
         
         // Call the callback function if it's set
         if(m_callback)
         {
            string selected_columns[];
            ArrayResize(selected_columns, m_num_columns);
            for(int i = 0; i < m_num_columns; i++)
            {
               selected_columns[i] = GetSelectedItemColumn(i);
            }
            m_callback(m_selected_index, selected_columns);
         }
      }
   }
   else if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int x = (int)lparam;
      int y = (int)dparam;
      int hovered_index = GetClickedItemIndex(x, y);
      if(m_hovered_index != hovered_index)
      {
         m_hovered_index = hovered_index;
         UpdateListDisplay();  // Update the entire display when hover changes
      }
   }
   else if(id == CHARTEVENT_MOUSE_WHEEL)
   {
      int scroll_delta = -(int)dparam / 120;
      m_scroll_position = MathMax(0, MathMin(ArraySize(m_items) - m_visible_items, m_scroll_position + scroll_delta));
      UpdateListDisplay();
      DrawScrollbar();
      
      m_hovered_index = -1;
   } 
}

//+------------------------------------------------------------------+
//| Add an item to the list                                          |
//+------------------------------------------------------------------+
void CTradeSelector::AddItem(const string &item_columns[])
{
   if(ArraySize(item_columns) != m_num_columns)
   {
      Print("Item does not have the correct number of columns.");
      return;
   }
   
   int size = ArraySize(m_items);
   ArrayResize(m_items, size + 1);
   ArrayResize(m_items[size].columns, m_num_columns);
   for(int i = 0; i < m_num_columns; i++)
   {
      m_items[size].columns[i] = item_columns[i];
   }
   
   UpdateListDisplay();
   DrawScrollbar();
}

//+------------------------------------------------------------------+
//| Handle key press events                                         |
//+------------------------------------------------------------------+
void CTradeSelector::HandleKeyPress(int key_code)
{
   switch(key_code)
   {
      case 38: // Up arrow
         MoveSelection(-1);
         break;
      case 40: // Down arrow
         MoveSelection(1);
         break;
      default:
         return;
   }
   
   if(m_callback && m_selected_index >= 0 && m_selected_index < ArraySize(m_items))
   {
      string selected_columns[];
      ArrayResize(selected_columns, m_num_columns);
      for(int i = 0; i < m_num_columns; i++)
      {
         selected_columns[i] = GetSelectedItemColumn(i);
      }
      m_callback(m_selected_index, selected_columns);
   }
}

//+------------------------------------------------------------------+
//| Move the selection by a given delta                             |
//+------------------------------------------------------------------+
void CTradeSelector::MoveSelection(int delta)
{
   int new_index = m_selected_index + delta;
   
   if(new_index < 0)
      new_index = 0;
   else if(new_index >= ArraySize(m_items))
      new_index = ArraySize(m_items) - 1;
   
   if(new_index != m_selected_index)
   {
      m_selected_index = new_index;
      
      // Adjust scroll position if necessary
      if(m_selected_index < m_scroll_position)
         m_scroll_position = m_selected_index;
      else if(m_selected_index >= m_scroll_position + m_visible_items)
         m_scroll_position = m_selected_index - m_visible_items + 1;
      
      UpdateListDisplay();
      DrawScrollbar();
   }
}

//+------------------------------------------------------------------+
//| Update the display of list items                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Update the display of list items                                |
//+------------------------------------------------------------------+
void CTradeSelector::UpdateListDisplay()
{
   int total_items = ArraySize(m_items);
   
   // Handle empty state
   if(total_items == 0)
   {
      // Calculate center position for message
      int total_width = 0;
      for(int k = 0; k < m_num_columns; k++)
         total_width += m_column_widths[k];
      
      string empty_message = "No trades are currently open";
      
      // Clear all existing labels and only show message in first column of first row
      for(int i = 0; i < m_visible_items; i++)
      {
         for(int j = 0; j < m_num_columns; j++)
         {
            string item_name = m_name + "Item" + IntegerToString(i) + "_" + IntegerToString(j);
            
            // Set empty string for all labels except the message in first position
            if(i == 0 && j == 0)
            {
               ObjectSetString(m_chart_id, item_name, OBJPROP_TEXT, empty_message);
               ObjectSetInteger(m_chart_id, item_name, OBJPROP_COLOR, m_text_color);
               ObjectSetInteger(m_chart_id, item_name, OBJPROP_XDISTANCE, m_x1 + (total_width - m_font_size * StringLen(empty_message)/2)/2);
            }
            else
            {
               // Explicitly set empty text for all other labels
               ObjectSetString(m_chart_id, item_name, OBJPROP_TEXT, " ");  // Use space instead of empty string
               // Move labels off-screen or set minimum width to 0 to hide them
               ObjectSetInteger(m_chart_id, item_name, OBJPROP_XDISTANCE, m_x1);
               ObjectSetInteger(m_chart_id, item_name, OBJPROP_WIDTH, 0);
            }
            
            // Hide the header labels when empty
            string header_name = m_name + "Header" + IntegerToString(j);
            if(j > 0)  // Keep only the first header visible for the message
            {
               ObjectSetString(m_chart_id, header_name, OBJPROP_TEXT, " ");
               ObjectSetInteger(m_chart_id, header_name, OBJPROP_WIDTH, 0);
            }
         }
      }
      
      ChartRedraw(m_chart_id);
      return;
   }

   // Show headers when items exist
   for(int j = 0; j < m_num_columns; j++)
   {
      string header_name = m_name + "Header" + IntegerToString(j);
      ObjectSetString(m_chart_id, header_name, OBJPROP_TEXT, m_headers[j]);
      ObjectSetInteger(m_chart_id, header_name, OBJPROP_WIDTH, m_column_widths[j]);
   }

   // Regular display logic for when items exist
   for(int i = 0; i < m_visible_items; i++)
   {
      int item_index = i + m_scroll_position;
      int current_x = m_x1 + 5;

      if(item_index < total_items)
      {
         color item_color = m_text_color;
         if(i == m_hovered_index)
            item_color = m_hover_color;
         if(item_index == m_selected_index)
            item_color = m_selected_color;

         for(int j = 0; j < m_num_columns; j++)
         {
            string item_name = m_name + "Item" + IntegerToString(i) + "_" + IntegerToString(j);
            ObjectSetString(m_chart_id, item_name, OBJPROP_TEXT, m_items[item_index].columns[j]);
            ObjectSetInteger(m_chart_id, item_name, OBJPROP_COLOR, item_color);
            ObjectSetInteger(m_chart_id, item_name, OBJPROP_XDISTANCE, current_x);
            ObjectSetInteger(m_chart_id, item_name, OBJPROP_WIDTH, m_column_widths[j]);
            current_x += m_column_widths[j];
         }
      }
      else
      {
         // Clear excess rows
         for(int j = 0; j < m_num_columns; j++)
         {
            string item_name = m_name + "Item" + IntegerToString(i) + "_" + IntegerToString(j);
            ObjectSetString(m_chart_id, item_name, OBJPROP_TEXT, " ");
            ObjectSetInteger(m_chart_id, item_name, OBJPROP_WIDTH, 0);
         }
      }
   }

   ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Print the selected item to the Experts log                      |
//+------------------------------------------------------------------+
void CTradeSelector::PrintSelectedItem()
{
   if(m_selected_index >= 0 && m_selected_index < ArraySize(m_items))
   {
      string item_details = "Selected Item [Index: " + IntegerToString(m_selected_index) + "]: ";
      for(int i = 0; i < m_num_columns; i++)
      {
         item_details += m_items[m_selected_index].columns[i];
         if(i < m_num_columns - 1)
            item_details += " | ";
      }
      Print(item_details);
   }
   else
   {
      Print("No item selected");
   }
}

//+------------------------------------------------------------------+
//| Get the index of the clicked item                               |
//+------------------------------------------------------------------+
int CTradeSelector::GetClickedItemIndex(const int x, const int y)
{
   if(x < m_x1 || x > m_x2 || y < m_y1 + 40 || y > m_y2)
      return -1;

   int item_height = (int)(m_font_size * 1.5);
   int clicked_index = (y - m_y1 - 40) / item_height;

   if(clicked_index >= 0 && clicked_index < m_visible_items)
      return clicked_index;

   return -1;
}

//+------------------------------------------------------------------+
//| Draw the scrollbar                                              |
//+------------------------------------------------------------------+
void CTradeSelector::DrawScrollbar()
{
   int total_items = ArraySize(m_items);
   if(total_items <= m_visible_items)
   {
      // Remove scrollbar if not needed
      ObjectDelete(m_chart_id, m_name + "ScrollbarBG");
      ObjectDelete(m_chart_id, m_name + "ScrollbarThumb");
      return;
   }

   int scrollbar_width = 8;
   int scrollbar_height = m_y2 - m_y1 - 40; // Adjust for header space
   double ratio = (double)m_visible_items / total_items;
   int thumb_height = MathMax((int)(ratio * scrollbar_height), 20);
   int thumb_pos = (int)(((double)m_scroll_position / (total_items - m_visible_items)) * (scrollbar_height - thumb_height));

   // Ensure thumb_pos is within bounds
   thumb_pos = MathMax(0, thumb_pos);
   thumb_pos = MathMin(scrollbar_height - thumb_height, thumb_pos);

   // Draw scrollbar background
   string scrollbar_bg_name = m_name + "ScrollbarBG";
   if(!ObjectCreate(m_chart_id, scrollbar_bg_name, OBJ_RECTANGLE_LABEL, m_subwin, 0, 0))
   {
      Print("Failed to create scrollbar background.");
      return;
   }
   ObjectSetInteger(m_chart_id, scrollbar_bg_name, OBJPROP_XDISTANCE, m_x2 - scrollbar_width);
   ObjectSetInteger(m_chart_id, scrollbar_bg_name, OBJPROP_YDISTANCE, m_y1 + 40);
   ObjectSetInteger(m_chart_id, scrollbar_bg_name, OBJPROP_XSIZE, scrollbar_width);
   ObjectSetInteger(m_chart_id, scrollbar_bg_name, OBJPROP_YSIZE, scrollbar_height);
   ObjectSetInteger(m_chart_id, scrollbar_bg_name, OBJPROP_BGCOLOR, m_border_color);
   ObjectSetInteger(m_chart_id, scrollbar_bg_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);

   // Draw scrollbar thumb
   string scrollbar_thumb_name = m_name + "ScrollbarThumb";
   if(!ObjectCreate(m_chart_id, scrollbar_thumb_name, OBJ_RECTANGLE_LABEL, m_subwin, 0, 0))
   {
      Print("Failed to create scrollbar thumb.");
      return;
   }
   ObjectSetInteger(m_chart_id, scrollbar_thumb_name, OBJPROP_XDISTANCE, m_x2 - scrollbar_width);
   ObjectSetInteger(m_chart_id, scrollbar_thumb_name, OBJPROP_YDISTANCE, m_y1 + 40 + thumb_pos);
   ObjectSetInteger(m_chart_id, scrollbar_thumb_name, OBJPROP_XSIZE, scrollbar_width);
   ObjectSetInteger(m_chart_id, scrollbar_thumb_name, OBJPROP_YSIZE, thumb_height);
   ObjectSetInteger(m_chart_id, scrollbar_thumb_name, OBJPROP_BGCOLOR, m_selected_color);
   ObjectSetInteger(m_chart_id, scrollbar_thumb_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);

   ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Set colors for the list selector                                 |
//+------------------------------------------------------------------+
void CTradeSelector::SetColors(color background, color border, color text, color selected, color hover, color header)
{
   m_background_color = background;
   m_border_color = border;
   m_text_color = text;
   m_selected_color = selected;
   m_hover_color = hover;
   m_header_color = header;

   ObjectSetInteger(m_chart_id, m_name, OBJPROP_BGCOLOR, m_background_color);
   ObjectSetInteger(m_chart_id, m_name, OBJPROP_BORDER_COLOR, m_border_color);

   // Update headers
   for(int i = 0; i < m_num_columns; i++)
   {
      string header_name = m_name + "Header" + IntegerToString(i);
      ObjectSetInteger(m_chart_id, header_name, OBJPROP_COLOR, m_header_color);
   }

   UpdateListDisplay();
   DrawScrollbar();
}

//+------------------------------------------------------------------+
//| Set font for the list selector                                   |
//+------------------------------------------------------------------+
void CTradeSelector::SetFont(const string& font_name, int font_size)
{
   m_font_name = font_name;
   m_font_size = font_size;

   // Update headers
   for(int i = 0; i < m_num_columns; i++)
   {
      string header_name = m_name + "Header" + IntegerToString(i);
      ObjectSetString(m_chart_id, header_name, OBJPROP_FONT, m_font_name);
      ObjectSetInteger(m_chart_id, header_name, OBJPROP_FONTSIZE, m_font_size + 2);
   }

   // Update list items
   for(int i = 0; i < m_visible_items; i++)
   {
      for(int j = 0; j < m_num_columns; j++)
      {
         string item_name = m_name + "Item" + IntegerToString(i) + "_" + IntegerToString(j);
         ObjectSetString(m_chart_id, item_name, OBJPROP_FONT, m_font_name);
         ObjectSetInteger(m_chart_id, item_name, OBJPROP_FONTSIZE, m_font_size);
      }
   }

   int item_height = (int)(m_font_size * 1.5);
   m_visible_items = (m_y2 - m_y1 - 40) / item_height; // Adjust for header space

   UpdateListDisplay();
   DrawScrollbar();
}

//+------------------------------------------------------------------+
//| Destroy the list selector and clean up resources                 |
//+------------------------------------------------------------------+
void CTradeSelector::Destroy()
{
   // Delete main rectangle
   ObjectDelete(m_chart_id, m_name);
   
   // Delete headers
   for(int i = 0; i < m_num_columns; i++)
   {
      ObjectDelete(m_chart_id, m_name + "Header" + IntegerToString(i));
   }
   
   // Delete list items
   for(int i = 0; i < m_visible_items; i++)
   {
      for(int j = 0; j < m_num_columns; j++)
      {
         ObjectDelete(m_chart_id, m_name + "Item" + IntegerToString(i) + "_" + IntegerToString(j));
      }
   }
   
   // Delete scrollbar
   ObjectDelete(m_chart_id, m_name + "ScrollbarBG");
   ObjectDelete(m_chart_id, m_name + "ScrollbarThumb");
}

//+------------------------------------------------------------------+
//| Get the index of the selected item                              |
//+------------------------------------------------------------------+
int CTradeSelector::GetSelectedIndex()
{
    return m_selected_index;
}

//+------------------------------------------------------------------+
//| Get the content of a specific column in the selected item       |
//+------------------------------------------------------------------+
string CTradeSelector::GetSelectedItemColumn(int column)
{
    if(m_selected_index >= 0 && m_selected_index < ArraySize(m_items))
    {
        if(column >=0 && column < m_num_columns)
            return m_items[m_selected_index].columns[column];
    }
    return "";
}

//+------------------------------------------------------------------+
//| *** New Public Method: ClearItems ***                            |
//+------------------------------------------------------------------+
void CTradeSelector::ClearItems()
{
    ArrayFree(m_items);
    m_selected_index = -1;
    m_scroll_position = 0;
    m_hovered_index = -1;
    UpdateListDisplay();
    DrawScrollbar();
}
