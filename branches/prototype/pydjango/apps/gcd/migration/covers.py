import os
import Image
import shutil
import stat
from datetime import timedelta

from django.conf import settings
from django.utils.encoding import smart_unicode as uni

from apps.gcd.models import Cover, Series

_local_scans_by_id = '/img/gcd/covers_by_id/'
_local_new_scans = '/img/gcd/new_covers/'
_local_scans = '/img/gcd/covers/'

def _create_cover_dir(scan_dir):
    if not os.path.isdir(scan_dir):
        if os.path.exists(scan_dir):
            return False
        else:
            os.mkdir(scan_dir)
    return True

def check_cover_dir(cover):
    """
    Checks if the necessary cover directories exist and creates
    them if necessary.
    """

    scan_dir = settings.MEDIA_ROOT + _local_scans_by_id + str(int(cover.id/1000))
    if not _create_cover_dir(scan_dir):
        return False
    if not _create_cover_dir(scan_dir + "/uploads"):
        return False
    if not _create_cover_dir(scan_dir + "/w100"):
        return False
    if not _create_cover_dir(scan_dir + "/w200"):
        return False
    if not _create_cover_dir(scan_dir + "/w400"):
        return False
    return True


def copy_covers_old():
    series=Series.objects.all().order_by('id')

    for serie in series:
        covers=Cover.objects.filter(has_image=True).filter(modified__lt='2009-10-02 14:00').filter(issue__series=serie)
        for cover in covers:
            old_filename = (str(cover.issue.series.id) + "/400/" + \
                             str(cover.series.id) + "_4_" + cover.code)
            old_filename = settings.MEDIA_ROOT + _local_scans + \
                                                 old_filename + ".jpg"
            new_filename = settings.MEDIA_ROOT + _local_scans_by_id + \
                           str(int(cover.id/1000)) + '/w400/' + str(cover.id) + ".jpg"
            check_cover_dir(cover)
            shutil.copy(old_filename,new_filename)
            os.chmod(new_filename, stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IROTH)
            try:
                 im = Image.open(new_filename)
            except IOError:
                 print cover.issue, old_filename, new_filename
                 raise
            # generate different sizes
            scaled_name = settings.MEDIA_ROOT + _local_scans_by_id + \
              str(int(cover.id/1000)) + "/w100/" + str(cover.id) + ".jpg"
            size = 100,int(100./im.size[0]*im.size[1])
            scaled = im.resize(size,Image.ANTIALIAS)
            scaled.save(scaled_name)

            scaled_name = settings.MEDIA_ROOT + _local_scans_by_id + \
              str(int(cover.id/1000)) + "/w200/" + str(cover.id) + ".jpg"
            size = 200,int(200./im.size[0]*im.size[1])
            scaled = im.resize(size,Image.ANTIALIAS)
            scaled.save(scaled_name)
        if serie.id % 500 == 0:
            print serie.id, serie

def find_original_cover(old_filename):
    extension = None
    if os.path.exists(old_filename + ".jpg"):
        extension = ".jpg"
        old_filename += ".jpg"
    elif os.path.exists(old_filename + ".JPG"):
        extension = ".jpg"
        old_filename += ".JPG"
    elif os.path.exists(old_filename + ".jpeg"):
        extension = ".jpg"
        old_filename += ".jpeg"
    elif os.path.exists(old_filename + ".tif"):
        extension = ".tif"
        old_filename += ".tif"
    elif os.path.exists(old_filename + ".gif"):
        extension = ".gif"
        old_filename += ".gif"
    elif os.path.exists(old_filename + ".png"):
        extension = ".png"
        old_filename += ".png"
    elif os.path.exists(old_filename + ".bmp"):
        extension = ".bmp"
        old_filename += ".bmp"
    return extension, old_filename

def copy_covers_new():
    covers=Cover.objects.filter(has_image=True).filter(modified__gte='2009-10-02 14:00')
    for cover in covers:
        issue = cover.issue
        scan_name = str(issue.series.id) + "_" + str(issue.id) + "_" + \
                    uni(issue).replace(' ','_').replace('/','-') + \
                    "_" + cover.modified.strftime('%Y%m%d_%H%M%S')
        upload_dir = settings.MEDIA_ROOT + _local_new_scans + \
                     cover.modified.strftime('%B_%Y/').lower()
        old_filename = upload_dir + scan_name 
        new_filename = settings.MEDIA_ROOT + _local_scans_by_id + \
                       str(int(cover.id/1000)) + '/uploads/' + str(cover.id) + cover.modified.strftime('_%Y%m%d_%H%M%S')
        check_cover_dir(cover)

        [extension, old_filename] = find_original_cover(old_filename)

        if not extension:
            scan_name = str(issue.series.id) + "_" + str(issue.id) + "_" + \
                        uni(issue).replace(' ','_').replace('/','-') + \
                        "_" + (cover.modified + timedelta(0,1)).strftime('%Y%m%d_%H%M%S')
            old_filename = upload_dir + scan_name 
            [extension, old_filename] = find_original_cover(old_filename)
            if not extension:
                print cover.issue, old_filename
                raise IOError

        new_filename += extension
        shutil.copy(old_filename,new_filename)
        os.chmod(new_filename, stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IROTH)

        im = Image.open(new_filename)
        if im.mode != "RGB":
            print "Image Mode:",im.mode
            im = im.convert("RGB")
        print cover.id, cover.issue, extension
        # generate different sizes (OK, we could just copy the files in this case...)
        scaled_name = settings.MEDIA_ROOT + _local_scans_by_id + \
          str(int(cover.id/1000)) + "/w100/" + str(cover.id) + ".jpg"
        size = 100,int(100./im.size[0]*im.size[1])
        scaled = im.resize(size,Image.ANTIALIAS)
        scaled.save(scaled_name)

        scaled_name = settings.MEDIA_ROOT + _local_scans_by_id + \
          str(int(cover.id/1000)) + "/w200/" + str(cover.id) + ".jpg"
        size = 200,int(200./im.size[0]*im.size[1])
        scaled = im.resize(size,Image.ANTIALIAS)
        scaled.save(scaled_name)

        scaled_name = settings.MEDIA_ROOT + _local_scans_by_id + \
          str(int(cover.id/1000)) + "/w400/" + str(cover.id) + ".jpg"
        size = 400,int(400./im.size[0]*im.size[1])
        scaled = im.resize(size,Image.ANTIALIAS)
        scaled.save(scaled_name)

        cover.file_extension = extension
        cover.save()


#copy_covers_old()
