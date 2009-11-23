import os
import Image
import shutil
import stat
import time
from urllib import urlretrieve
from datetime import timedelta, datetime

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
    series=Series.objects.all().order_by('id').filter(id=13589)

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
    #covers=Cover.objects.filter(has_image=True).filter(modified__gte='2009-10-02 14:00').filter(modified__lt='2009-11-15 00:00')
    #covers=Cover.objects.filter(has_image=True).filter(modified__gte='2009-11-15 00:00').filter(modified__lt='2009-11-23 00:00')
    covers=Cover.objects.filter(has_image=True).filter(modified__gte='2009-11-23 00:00')

    cnt = 0
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
        cnt+=1
        if cnt % 100 == 0:
            print cnt

def generate_sizes(cover, filename):
    im = Image.open(filename)
    if im.mode != "RGB":
        print "Image Mode:",im.mode
        im = im.convert("RGB")
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

# copy the content of the cover to a newly generated cover
# doing it this way makes sure that the variant cover ids are in the same order
# as originally uploaded...
def copy_cover_content(cover, for_real=False):
    old_filename = settings.MEDIA_ROOT + _local_scans_by_id + \
                   str(int(cover.id/1000)) + '/uploads/' + str(cover.id) + \
                   cover.modified.strftime('_%Y%m%d_%H%M%S') + cover.file_extension
    if not os.path.exists(old_filename):
        print old_filename
        raise IOError
    if for_real:
        variant = Cover(series=cover.series,
                        issue=cover.issue,
                        code=cover.code,
                        has_image=True,
                        server_version=1,
                        contributor=cover.contributor,
                        marked=False,
                        created=cover.modified,
                        modified=cover.modified,
                        variant_code='1',
                        file_extension=cover.file_extension)
        variant.save() # without save we don't have an id if I am not mistaken
        check_cover_dir(variant)
        new_filename = settings.MEDIA_ROOT + _local_scans_by_id + \
                       str(int(variant.id/1000)) + '/uploads/' + str(variant.id) + \
                       variant.modified.strftime('_%Y%m%d_%H%M%S') + cover.file_extension
        shutil.move(old_filename,new_filename)
        generate_sizes(variant, new_filename)

def add_variants(for_real=False):
    file = open('sorted_variants')
    lines = file.readlines()
    issue_old = -1
    for line in lines:
        content = line.split('; ')
        series = int(content[0])
        issue = int(content[1])
        #modified = datetime.strptime(content[2], '%Y%m%d_%H%M%S')
        modified = datetime(*(time.strptime(content[2], '%Y%m%d_%H%M%S')[0:6]))
        backup_filename = content[3]
        next_filename = content[4]
        contributor = content[5].split('\n')[0]
        cur_cover = Cover.objects.filter(issue__id = issue).latest()
        if issue_old == issue: # we only the old datetime for the first file from the old db,
                               # the datetime in the case of more than one variant we need to get
                               # from the last used filename (that's why they are sorted by issue.id)
            if for_real and cur_cover == cover_old: # this shouldn't happen
                #modified = datetime.strptime(os.path.splitext(last_uploaded)[0][-15:], '%Y%m%d_%H%M%S')
                modified = datetime(*(time.strptime(os.path.splitext(last_uploaded)[0][-15:], '%Y%m%d_%H%M%S')[0:6]))
                print last_uploaded, modified
                print cur_cover.issue, backup_filename, next_filename
                raise ValueError
            else:
                #modified = datetime.strptime(os.path.splitext(last_uploaded)[0][-15:], '%Y%m%d_%H%M%S')
                modified = datetime(*(time.strptime(os.path.splitext(last_uploaded)[0][-15:], '%Y%m%d_%H%M%S')[0:6]))
                print last_uploaded, modified
                print cur_cover.issue, backup_filename, next_filename
        copy_cover_content(cur_cover, for_real)

        # series, issues, code, has_image, server_version stays the same
        if for_real:
            cur_cover.contributor=contributor
            cur_cover.modified=modified
            cur_cover.file_extension=None
        else:
            print "changed contributor", cur_cover.contributor, contributor
            print "changed modified", cur_cover.modified, modified

        if modified > datetime(2009, 10, 02, 14, 0, 0): # we have the uploaded file
            scan_filename = str(cur_cover.issue.series.id) + "_" + str(cur_cover.issue.id) + "_" + \
                            uni(cur_cover.issue).replace(' ','_').replace('/','-') + \
                            "_" + cur_cover.modified.strftime('%Y%m%d_%H%M%S')
            upload_dir = settings.MEDIA_ROOT + _local_new_scans + \
                         cur_cover.modified.strftime('%B_%Y/').lower()
            [extension, scan_filename] = find_original_cover(upload_dir + scan_filename)
            if not for_real:
                print "--------------------", extension, scan_filename
            if not extension:
                raise IOError
            cur_cover.file_extension = extension
            new_filename = settings.MEDIA_ROOT + _local_scans_by_id + \
                           str(int(cur_cover.id/1000)) + '/uploads/' + str(cur_cover.id) + \
                           cur_cover.modified.strftime('_%Y%m%d_%H%M%S') + cur_cover.file_extension
            if for_real:
                shutil.copy(scan_filename,new_filename)
                generate_sizes(cur_cover, new_filename)
        else: # we don't, so we use the backup
            old_filename = settings.MEDIA_ROOT + '/img/gcd/' + backup_filename
            if not os.path.exists(old_filename):
                print old_filename
                print 'wget images.comics.org/img/gcd/' + backup_filename
		urlretrieve('http://images.comics.org/img/gcd/' + backup_filename, old_filename)
                #raise IOError
            if for_real:
                cur_cover.file_extension = '.jpg'
                # not really the uploaded file
                new_filename = settings.MEDIA_ROOT + _local_scans_by_id + \
                               str(int(cur_cover.id/1000)) + '/uploads/' + str(cur_cover.id) + \
                               cur_cover.modified.strftime('_%Y%m%d_%H%M%S') + cur_cover.file_extension
                shutil.copy(old_filename,new_filename)
                generate_sizes(cur_cover, new_filename)
        if for_real:
            cur_cover.save()
            print cur_cover.issue.id, cur_cover.issue
        issue_old = issue
        last_uploaded = next_filename
        cover_old = cur_cover

add_variants(for_real=True)
#copy_covers_new()
#copy_covers_old()
