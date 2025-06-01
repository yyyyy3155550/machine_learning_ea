import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
import joblib
import os

# データ読み込み
df = pd.read_csv("../ML1/data/features.csv")

# 説明変数（特徴量）と目的変数（ターゲット）を分ける
X = df[["close", "ema_5", "ema_20", "rsi_14", "atr"]]
y = df["target"]

# 学習用データとテスト用データに分割（8:2）
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42  #シード値は適当。42はおまじないらしい。よくわからんけど。テストの再現性を保つために設定
)

# モデル作成＆学習
clf = RandomForestClassifier(n_estimators=100, random_state=42) #上の乱数シードとは別。RandomForestの再現性を保つために設定 clfにはモデルが格納される
clf.fit(X_train, y_train) #簡単に言うと、x(特徴量)をインプットにy(ターゲット)を出力できるように学習しろよ？ってこと？

# テストデータで、テスト＆評価
y_pred = clf.predict(X_test) #モデルを実際に動かす(X_testで予測させる)。 y_predはモデルの出力結果が格納される
print('report',classification_report(y_test, y_pred)) # テスト分の出力結果と正解ラベルを入れて、評価レポートを作る

# モデル保存
os.makedirs("../ML1/models", exist_ok=True)
joblib.dump(clf, "../ML1/models/model.joblib")
print("✅ モデルを保存しました: ../ML1/models/model.joblib")
