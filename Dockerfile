# Sử dụng image Odoo 19 chính thức
FROM odoo:19

# Chuyển sang quyền root để copy file
USER root

# Copy file cấu hình
COPY odoo.conf /etc/odoo/odoo.conf

# Nếu sau này có module riêng thì bỏ comment 2 dòng dưới
# COPY custom_addons /mnt/extra-addons
# RUN chown -R odoo:odoo /mnt/extra-addons

# Trở về user odoo
USER odoo

EXPOSE 8069

CMD ["odoo", "-c", "/etc/odoo/odoo.conf", "-i", "base"]