# FINAL SETUP — READ THIS FIRST

## If you already imported the OLD FitCore database
Import **database/upgrade_to_final.sql** only.

This adds the final-version tables/settings without dropping your existing members, payments, attendance or other original records.

## If you want a clean FINAL demo database
Import **database/fitcore.sql** only.

This recreates the complete database and loads final demo data.

### Do not import schema.sql + seed.sql + fitcore.sql together.
`fitcore.sql` already contains the full schema and demo data.

## Staff login
admin@fitcore.com / admin123

## Member portal
member@fitcore.com / member123

## Main URL
If the folder name is `fitcore_pro_final`:
http://localhost/fitcore_pro_final/

If you rename the folder to `fitcore_pro`:
http://localhost/fitcore_pro/
