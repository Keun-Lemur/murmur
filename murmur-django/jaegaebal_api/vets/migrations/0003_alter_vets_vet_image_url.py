# Generated by Django 5.1.1 on 2024-09-13 09:56

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('vets', '0002_alter_vets_tele_consultation'),
    ]

    operations = [
        migrations.AlterField(
            model_name='vets',
            name='vet_image_url',
            field=models.URLField(blank=True, max_length=500, null=True),
        ),
    ]
