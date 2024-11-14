//+------------------------------------------------------------------+
//|                                                MainPanelEA.mq5   |
//|           Expert Advisor to Use the MainPanel GUI                |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#include <TradingDashboard/MainPanel.mqh>

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
MainPanel *panel = NULL;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    panel = new MainPanel();
    if(!panel.Initialize())
    {
        delete panel;
        panel = NULL;
        return INIT_FAILED;
    }
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    if(panel != NULL)
    {
        panel.Deinitialize(reason);
        delete panel;
        panel = NULL;
    }
}

//+------------------------------------------------------------------+
//| Chart event function                                             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    if(panel != NULL)
    {
        panel.HandleChartEvent(id, lparam, dparam, sparam);
    }
}

