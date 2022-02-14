from google.cloud import firestore

def quickstart_get_collection():
    db = firestore.Client(project='my-project-id')
    users_ref = db.collection(u'users')
    docs = users_ref.stream()

    for doc in docs:
        print(f'{doc.id} => {doc.to_dict()}')