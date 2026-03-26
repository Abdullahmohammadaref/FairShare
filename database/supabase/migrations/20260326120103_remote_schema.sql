alter table "public"."Members" drop constraint "Members_user_id_fkey";

alter table "public"."Members" drop column "user_id";

alter table "public"."Rooms" drop column "name";


