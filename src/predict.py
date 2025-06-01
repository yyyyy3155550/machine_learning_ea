import sys
import pandas as pd
import joblib

# 1. モデルのロード
#　学習してjoblibで保存したモデルを読み込む
model = joblib.load("../ML1/models/model.joblib")

# 2. 予測用の特徴量をCSVで受け取る
# 例: python src/predict.py ../ML1/data/test_feature.csv
# コマンドうつとき、メインのスクリプトファイルと何かほかのファイルを引数にした時、sys.argv[1]で使えるようになる
if len(sys.argv) < 2:   # コマンド打つとき、引数がなかった場合１になるので、2未満でtrueになる 
    print("Usage: python predict.py [特徴量CSVファイル]")
    sys.exit(1)  # 終了　1は以上を表す。つまり、異常終了

input_csv = sys.argv[1]  # コマンド時に渡された引数を受け取り 
df = pd.read_csv(input_csv)  #pdでCSVを読み込む

# 3. 必要なカラムのみ抽出
X = df[["close", "ema_5", "ema_20", "rsi_14", "atr"]]

# 4. 予測
pred = model.predict(X)[0]  # predict(x)の予測結果インデックス0→すなわち1行目を指定。predに格納
print(pred)  # 標準出力に0か1
