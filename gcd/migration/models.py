from django.db import models

"""
The tables in this application store transient migration data in order
to keep it separate from the main schema and data.
"""

class SequenceStatus(models.Model):
    """
    Migration data for the Sequence table.

    Status flags in this table must indicate the data to which they apply,
    as few things will apply to the whole row.
    """

    class Meta:
        app_label = 'migration'
        db_table = 'migration_sequence_status'
        verbose_name_plural = 'sequence_statuses'

    sequence = models.OneToOneField('core.Sequence',
                                     related_name='migration_data')

    reprint_needs_inspection = models.NullBooleanField(blank=True)
    reprint_confirmed = models.NullBooleanField(blank=True)
    reprint_original_notes = models.TextField(blank=True)

    def __unicode__(self):
        return u'%s: Sequence %d: %s' % (self.sequence.issue,
                                         self.sequence.number,
                                         self.sequence)

