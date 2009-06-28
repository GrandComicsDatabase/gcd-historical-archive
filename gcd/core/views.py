from django.shortcuts import render_to_response


def oops(request):
    """
    Generates the "not implemented yet" page.
    """
    return render_to_response('core/oops.html')

