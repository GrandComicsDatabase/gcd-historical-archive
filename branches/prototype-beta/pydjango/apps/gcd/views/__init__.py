from urllib import quote
from django.conf import settings
from django.core.paginator import QuerySetPaginator
from django.http import HttpResponseRedirect
from django.template import RequestContext
from django.shortcuts import render_to_response

from pagination import DiggPaginator

ORDER_ALPHA = "alpha"
ORDER_CHRONO = "chrono"

def index(request):
    """Generates the front index page."""

    style = 'default'
    if 'style' in request.GET:
        style = request.GET['style']

    vars = { 'style' : style }
    return render_to_response('gcd/index.html', vars,
                              context_instance=RequestContext(request))
      

def paginate_response(request, queryset, template, vars, page_size=100,
                      callback_key=None, callback=None):
    """
    Uses DiggPaginator from
    http://bitbucket.org/miracle2k/djutils/src/tip/djutils/pagination.py.
    We could reconsider writing our own code.
    """

    p = DiggPaginator(queryset, page_size, body=5, padding=2)

    page_num = 1
    redirect = None
    if ('page' in request.GET):
        try:
            page_num = int(request.GET['page'])
            if page_num > p.num_pages:
                redirect = p.num_pages
            elif page_num < 1:
                redirect = 1
        except ValueError:
            redirect = 1

    if redirect is not None:
        args = request.GET.copy()
        args['page'] = redirect
        return HttpResponseRedirect(quote(request.path.encode('UTF-8')) +
                                    u'?' + args.urlencode())

    page = p.page(page_num)

    vars['items'] = page.object_list
    vars['paginator'] = p
    vars['page'] = page
    vars['page_number'] = page_num

    if callback_key is not None:
        vars[callback_key] = callback(page)

    return render_to_response(template, vars,
                              context_instance=RequestContext(request))

