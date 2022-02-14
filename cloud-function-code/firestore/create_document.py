from google.cloud import firestore

def main(event, context):
    db = firestore.Client(project='my-project-id')
    doc_ref = db.collection(u'users').document(u'alovelace')
    doc_ref.set({
        u'first': u'Ada',
        u'last': u'Lovelace',
        u'born': 1815
    })