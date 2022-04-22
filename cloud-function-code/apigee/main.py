from flask import Response

def product(request):
    try:
        body = request.get_json()

        result = int(body["a"]) * int(body["b"])
        return Response(f"{{'result':{result}}}", status=200, mimetype='application/json')
    except:
        return Response(f"{{'error':'Invalid request'}}", status=400, mimetype='application/json')