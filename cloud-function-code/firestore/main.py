from google.cloud import firestore

def add_document(event, context):
    print(event)
    db = firestore.Client(project='my-project-id')
    doc_ref = db.collection(u'users').document(u'alovelace')
    doc_ref.set({
        u'first': u'Ada',
        u'last': u'Lovelace',
        u'born': 1815
    })

def get_collection(event, context):
    print(event)
    db = firestore.Client(project='my-project-id')
    users_ref = db.collection(u'users')
    docs = users_ref.stream()

    for doc in docs:
        print(f'{doc.id} => {doc.to_dict()}')

