import pandas as pd
import ta  # taライブラリが必要
import os

# データ読み込み
df = pd.read_csv("../ML1/data/raw_data.csv")
df["time"] = pd.to_datetime(df["time"])

# テクニカル指標を追加
# taのEMAインジケータを使って計算（EMA5, EMA20）
df["ema_5"] = ta.trend.ema_indicator(df["close"], window=5)
df["ema_20"] = ta.trend.ema_indicator(df["close"], window=20)
# RSI（14）
df["rsi_14"] = ta.momentum.rsi(df["close"], window=14)
# ATR（14）
df["atr"] = ta.volatility.average_true_range(
    df["high"], df["low"], df["close"], window=14
)

# ラベル（次の足の終値が上がる場合1、下がる場合0）
df["target"] = (df["close"].shift(-1) > df["close"]).astype(int) #astype(int)でboolをintに変換 0\1のラベリングができる

# 必要な列だけに整理
df = df[["time", "close", "ema_5", "ema_20", "rsi_14", "atr", "target"]]
df = df.dropna()  # 欠損値を削除

# 保存
os.makedirs("../ML1/data", exist_ok=True)
df.to_csv("../ML1/data/features.csv", index=False)
print("✅ 特徴量データを保存しました: ../ML1/data/features.csv")
