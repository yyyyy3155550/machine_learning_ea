import MetaTrader5 as mt5
import pandas as pd
import os
import time

# MT5 のインストールパスを指定
mt5_path = r"C:\Program Files\MetaTrader 5 -2\terminal64.exe"  # r (raw)を最初に入れて、\問題解決

# MT5 プロセスが動いているか確認
if os.path.exists(mt5_path):
    os.startfile(mt5_path)  # 指定した MT5 を起動
    print("指定された MT5 を起動。")
else:
    print("指定された MT5 が見つかりません")

time.sleep(2) # Initial前に2秒待機

# MetaTrader 5 (MT5) 初期化
mt5.initialize()

# 通貨ペアと期間設定
SYMBOL = "EURUSD"  # 任意の通貨ペア
TIMEFRAME = mt5.TIMEFRAME_H1  # 1時間足 (H1)
NUM_BARS = 24 * 365 * 3  # 3年分のデータ (1H 足)

# データ取得
rates = mt5.copy_rates_from_pos(SYMBOL, TIMEFRAME, 0, NUM_BARS)
mt5.shutdown()

# データをデータフレーム化
df = pd.DataFrame(rates)
df["time"] = pd.to_datetime(df["time"], unit="s") # detaframeのtime(unixtime秒)を datetime型に変換

# 保存ディレクトリ (ML1/data) を作成
os.makedirs("../ML1/data", exist_ok=True)
df.to_csv("../ML1/data/raw_data.csv", index=False)
print("✅ データを保存しました: ../ML1/data/raw_data.csv")
