import stripe
from firebase_functions import https_fn
from firebase_admin import initialize_app

app = initialize_app()


@https_fn.on_request()
def stripe_pay_method_id(req: https_fn.Request) -> https_fn.Response:
    print(req.method, req.get_json())
    
    if req.method != "POST":
        return https_fn.Response(status=403, response="Forbodden")
    
    data = req.get_json()
    payment_method_id = data.get('paymentMethodId')
    items = data.get('items')
    currency = data.get('currency')
    use_stripe_sdk = data.get('useStripeSdk')

    # TODO: Calculate the total price
    total = 1400

    try:
        if payment_method_id:
           params = {}
           intent = stripe.PaymentIntent.create()

    except Exception as e:
        return https_fn.Response(status=500, response=str(e))