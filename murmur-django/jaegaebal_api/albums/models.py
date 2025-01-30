from django.db import models


class Albums(models.Model):
    album_subtitle = models.TextField(blank=False, null=False)
    album_title = models.TextField(blank=False, null=False)
    album_image = models.URLField(max_length=255, blank=True, null=True)

    # 수의사와의 다대다 관계
    vet = models.ManyToManyField("vets.Vets", related_name="albums", blank=True)

    def __str__(self):
        return self.album_title
