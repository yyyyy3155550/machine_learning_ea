# ML_EA – Python連携 機械学習トレーディングEA

## 概要

MetaTrader 5（MQL5）とPythonを連携させ、機械学習モデル/ランダムフォレストによる売買判断を行うEAです。  
データ取得・特徴量生成・学習・予測まで一連の流れをPython側で構築し、  
MQL5からはPythonスクリプトを呼び出してモデル予測結果を取得・売買ロジックに反映します。

---

## ディレクトリ構成

![スクリーンショット 2025-06-02 132648](https://github.com/user-attachments/assets/b56f5f33-d062-47f9-a719-9dea71ce36c6)

---

## 主なファイル・役割

- **data/**  
  - `raw_data.csv`：価格データ  
  - `features.csv`：特徴量データ/ラベル  
  - `test_feature.csv`：簡易テスト用特徴量データ
- **models/**  
  - `model.joblib`：学習済み機械学習モデル
- **src/**  
  - `ML_EA.mq5`：MQL5本体（EAコード）
  - `ML_EA.ex5`：コンパイル済みEA
  - `fetch_data.py`：MT5または外部からデータ取得
  - `preprocess_data.py`：データ前処理・特徴量生成
  - `train_model.py`：モデル学習
  - `predict.py`：モデルを使って予測（MQLから呼び出される）
 
---

## システム構成・処理フロー

1. **データ準備**  
   `fetch_data.py`でMT5からデータを収集  
2. **特徴量生成/データ処理・整形/ラベリング**  
   `preprocess_data.py`で特徴量を作成。具体的には、raw_dataから特徴量となるテクニカル指標を計算し算出。
   欠損値処理等データ整形をして、目標変数をラベリングし、`features.csv`に保存
4. **機械学習モデル学習**  
   `train_model.py`でモデルを学習し、`models/model.joblib`として保存
5. **EAでの運用**  
   - `ML_EA.mq5`（MQL5 EA）は、取引タイミングでAPI`shell32.dll`や`ShellExecuteW`等を使い、`predict.py`を呼び出す  
   - `predict.py`が特徴量をもとに学習済みモデルで予測→判定結果をEA側に返す
   - EAは返り値に応じて売買

---

## 主要パラメータ例（EA側）
パラメーターはありません。  
以下にチェックを入れて設定は終了です。　　
![スクリーンショット 2025-06-01 160936](https://github.com/user-attachments/assets/a8213aed-6021-4f37-b4f8-4d41e8c2caab)


---

## 使い方

1. 必要なPythonライブラリをインストール（例: pandas, scikit-learn, joblib）
2. `train_model.py`でモデルを学習し、`models/model.joblib`を生成
3. `ML_EA.mq5`をMetaTrader 5でコンパイルし、チャートに適用
4. 必要パスなどパラメータをEAで設定
5. EAが自動で`predict.py`を呼び出して予測→判定結果で売買

---

### 必要なPythonライブラリ

- MetaTrader5(データ取得用。必要に応じて)
- pandas
- ta
- scikit-learn
- joblib

#### インストール例
`pip install MetaTrader5 pandas ta scikit-learn joblib`

---

## 注意事項・推奨

- ファイルパスは各自の環境に合わせて設定
- サンプルは検証・学習目的です。運用は十分な検証の上自己責任で

---

## バックテスト
### 2015年から10年分

![TesterGraphReport](https://github.com/user-attachments/assets/4c321bac-b7d3-425a-b4f5-f771ede5ebf7)
![ReportTester](https://github.com/user-attachments/assets/2d7d2d17-eb2b-4bb3-ad06-0456789ba7bc)
![ReportTester](https://github.com/user-attachments/assets/771d3117-8ed9-42e5-a83d-1506bf6e6122)
![ReportTester](https://github.com/user-attachments/assets/c50242b2-f344-4f3e-9fb7-6213998a1142)
![ReportTester](https://github.com/user-attachments/assets/44d9f2ce-2736-48b8-94ea-764d62d6721f)
![スクリーンショット](https://github.com/user-attachments/assets/4fc407d3-d38d-4d22-893c-b055011c0287)
![スクリーンショット](https://github.com/user-attachments/assets/01d3103c-83cd-4dac-a976-ee42113a30b4)

### サンプル動画 (ビジュアルバックテスト)



https://github.com/user-attachments/assets/e58b0361-14bf-4317-abb5-22aa08e2b60e






---
