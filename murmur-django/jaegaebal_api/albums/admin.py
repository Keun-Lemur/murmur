from django.contrib import admin
from .models import Albums


class AlbumsAdmin(admin.ModelAdmin):
    list_display = ("album_title", "album_image")

    def get_vets(self, obj):
        return "\n".join([vet.vet_name for vet in obj.vet.all()])

    get_vets.short_description = "Vets"


admin.site.register(Albums, AlbumsAdmin)
