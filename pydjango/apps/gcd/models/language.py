from django.db import models

class Language(models.Model):
    class Meta:
        app_label = 'gcd'
        ordering = ('name',)

    code = models.CharField(max_length=10)
    name = models.CharField(max_length=255)

    def __unicode__(self):
        return self.name

