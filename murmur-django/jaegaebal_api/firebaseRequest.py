import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Firebase 서비스 계정 키 파일 경로
cred = credentials.Certificate(
    "/Users/hyungkeunkang/jaegaebal_api/jaegaebal_api/firebaseConfig.json"
)

# Firebase 앱 초기화
firebase_admin.initialize_app(cred)

# Firestore 데이터베이스 클라이언트 가져오기
db = firestore.client()

# Firebase 데이터베이스에서 데이터 가져오기
ref = db.collection("vetrInput")  # 'vetrInput' 컬렉션의 모든 데이터 가져오기
docs = ref.stream()

# Firestore 문서 데이터를 리스트로 변환
doc_list = [doc.to_dict() for doc in docs]

# JSON 형식으로 변환 및 저장
import json

with open("get_data.json", "w") as f:
    json.dump(doc_list, f, indent=2)

print("Firestore 데이터가 'get_data.json' 파일에 저장되었습니다.")
