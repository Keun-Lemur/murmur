from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Albums
from .serializers import AlbumsSerializer


@api_view(["GET"])
def get_albums(request):
    """
    GET 요청으로 모든 앨범을 반환하는 API
    """

    albums = Albums.objects.all()

    serializer = AlbumsSerializer(albums, many=True)

    return Response(serializer.data)
