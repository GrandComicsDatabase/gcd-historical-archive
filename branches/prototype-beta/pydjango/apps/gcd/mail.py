import socket
from django.conf import settings

# Python:  Not the best with library/version compatibility.
try:
    from email.mime.text import MIMEText
except ImportError:
    from email.MIMEText import MIMEText
import smtplib

def send_email(from_addr, to_addrs, subject, body):
    """
    email sending shortcut.
    from_addr: A single address.
    to_addrs: A list or tuple of addresses.
    subject: The subject as a string.
    body: The body as a string.
    """

    try:
        server = smtplib.SMTP('localhost')
        msg = MIMEText(body.encode('UTF-8'))
        msg['To'] = ', '.join(to_addrs)
        msg['From'] = from_addr
        msg['Subject'] = subject
        server.sendmail(from_addr, to_addrs, msg.as_string())
        server.quit()
    except socket.error:
        # No local mail.  Fail silently unless we're in BETA mode.
        if settings.BETA:
            raise

def email_editors(from_addr, subject, body):
    return send_email(from_addr=from_addr,
                      to_addrs=[settings.EMAIL_EDITORS],
                      subject=subject,
                      body=body)

