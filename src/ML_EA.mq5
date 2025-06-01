//+------------------------------------------------------------------+
//|                                             ML_EA.mq5           |
//|                          Machine Learning EA: Python Model      |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict //おまじない

#include <Trade/Trade.mqh>
CTrade trade;

// ShellExecuteW を Windows API からインポート
#import "shell32.dll"
int ShellExecuteW(int hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
#import // importではじめて、importの終わる


// Python 実行設定
string pythonPath  = "python";  // 環境に合わせて調整
string scriptPath  = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\predict.py";  //mt5のファルダパスを取得+\\MQL5\\Files\\predict.pyをつけてして、特定ファイルパスにする

// ファイル名（MQL5/Files フォルダ内）
string featureFile = "feature.csv"; // 特徴量を保存するファイル名
string resultFile  = "result.txt"; // 予測結果を保存するファイル名



//+------------------------------------------------------------------+
//| インジケーター計算関数                                            |
//+------------------------------------------------------------------+
double ComputeEMA(int period)
{
   // iMA(symbol, timeframe, period, shift, method, applied_price)
   return iMA(_Symbol, PERIOD_H1, period, 0, MODE_EMA, PRICE_CLOSE);
}

double ComputeRSI(int period)
{
   // iRSI(symbol, timeframe, period, applied_price)
   return iRSI(_Symbol, PERIOD_H1, period, PRICE_CLOSE);
}

double ComputeATR(int period)
{
   // ATRインジケータのハンドルを作成
   int atr_handle = iATR(_Symbol, PERIOD_H1, period);
   if(atr_handle == INVALID_HANDLE)
   {
      Print("Failed to create ATR handle");
      return 0.0;
   }

   // 最新バーのATR値を取得
   double atr_buffer[];
   if(CopyBuffer(atr_handle, 0, 0, 1, atr_buffer) <= 0)
   {
      Print("Failed to copy ATR buffer");
      IndicatorRelease(atr_handle);
      return 0.0;
   }
   IndicatorRelease(atr_handle);
   return atr_buffer[0];

}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("ML_EA initialized");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // ポジションがある場合はスキップ
   if(PositionSelect(_Symbol)) return;

   // 1. 特徴量を CSV に書き出し
   int fh = FileOpen(featureFile, FILE_WRITE|FILE_CSV|FILE_ANSI); //ファイル名だけしか指定してないが自動的にMQL5/Files/になる。ファイルが存在していなければ、新規作成される。
   if(fh == INVALID_HANDLE)
   {
      Print("Failed to open feature file: ", featureFile);
      return;
   }
   //まずはヘッダー、カラム名を１行目にいれる。
   FileWrite(fh, "close", "ema_5", "ema_20", "rsi_14", "atr");

   //double close0 = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double close0 = iClose(_Symbol, PERIOD_H1, 0); // 現在の1時間足の終値を取得
   double ema5   = ComputeEMA(5);
   double ema20  = ComputeEMA(20);
   double rsi14  = ComputeRSI(14);
   double atr14  = ComputeATR(14); 

   // 特徴量をファイルに書き込む
   FileWrite(fh,
             DoubleToString(close0, _Digits),//doubleを文字列に
             DoubleToString(ema5,   _Digits),
             DoubleToString(ema20,  _Digits),
             DoubleToString(rsi14,  _Digits),
             DoubleToString(atr14,  _Digits));
   FileClose(fh); //書き終わったのでファイルを閉じる


   // 2. Python predict.py を実行し結果を result.txt にリダイレクト
   string fullFeature = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\" + featureFile;
   string fullResult  = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\" + resultFile;

   string cmd = pythonPath + " \"" + scriptPath + "\" \"" + fullFeature + "\" > \"" + fullResult + "\""; //＞をつかうと、出力結果をファイルに書き込める。カジュアルな書き方

   //ここで、コマンドとともに引数でfullパスを書いて引き渡す。そうやってMQLとPythonを連携させる。。

   ShellExecuteW(0, "open", "cmd.exe", "/C " + cmd, "", 0); //　コマンド実行


   // python実行待ち
   Sleep(1000);


   // 3. 結果を読み込む
   fh = FileOpen(resultFile, FILE_READ|FILE_TXT|FILE_ANSI);
   if(fh == INVALID_HANDLE)
   {
      Print("Failed to open result file: ", resultFile);
      return;
   }
   string result = FileReadString(fh);
   FileClose(fh);
   int pred = (StringToInteger(result) == 1) ? 1 : 0; //中身が1or0ならそれをpredに格納
   PrintFormat("Prediction result: %d", pred);

   // 4. 売買ロジック（ATRベースのSL/TP）
   double lotSize = 0.1;
   double slDist  = atr14 * 1.5;

   double buy_price   = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double buy_sl      = buy_price - slDist;
   double buy_tp      = buy_price + slDist * 1.5;

   double sell_price  = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sell_sl     = sell_price + slDist;
   double sell_tp     = sell_price - slDist * 1.5;

   PrintFormat("ATR(14): %.5f", atr14);
   PrintFormat("SL Distance: %.5f", slDist);

   PrintFormat("Buy: price=%.5f, SL=%.5f, TP=%.5f", buy_price, buy_sl, buy_tp);
   PrintFormat("Sell: price=%.5f, SL=%.5f, TP=%.5f", sell_price, sell_sl, sell_tp);
   
   if(pred == 1)
   {
      if(!PositionSelect(_Symbol))
         trade.Buy(lotSize, _Symbol, buy_price, buy_sl, buy_tp);
      PrintFormat("Buy order sent at %.5f", buy_price);
   }
   else
   {
      if(!PositionSelect(_Symbol))
         trade.Sell(lotSize, _Symbol, sell_price, sell_sl, sell_tp);
      PrintFormat("Sell order sent at %.5f", sell_price);
   }
}

//+------------------------------------------------------------------+
