drop policy "create item" on "public"."items";

drop policy "select item" on "public"."items";

drop policy "create member" on "public"."members";

drop policy "select member" on "public"."members";

drop policy "create room" on "public"."rooms";

drop policy "select room" on "public"."rooms";

revoke delete on table "public"."items" from "anon";

revoke insert on table "public"."items" from "anon";

revoke references on table "public"."items" from "anon";

revoke select on table "public"."items" from "anon";

revoke trigger on table "public"."items" from "anon";

revoke truncate on table "public"."items" from "anon";

revoke update on table "public"."items" from "anon";

revoke delete on table "public"."items" from "authenticated";

revoke insert on table "public"."items" from "authenticated";

revoke references on table "public"."items" from "authenticated";

revoke select on table "public"."items" from "authenticated";

revoke trigger on table "public"."items" from "authenticated";

revoke truncate on table "public"."items" from "authenticated";

revoke update on table "public"."items" from "authenticated";

revoke delete on table "public"."items" from "service_role";

revoke insert on table "public"."items" from "service_role";

revoke references on table "public"."items" from "service_role";

revoke select on table "public"."items" from "service_role";

revoke trigger on table "public"."items" from "service_role";

revoke truncate on table "public"."items" from "service_role";

revoke update on table "public"."items" from "service_role";

revoke delete on table "public"."items_proportions" from "anon";

revoke insert on table "public"."items_proportions" from "anon";

revoke references on table "public"."items_proportions" from "anon";

revoke select on table "public"."items_proportions" from "anon";

revoke trigger on table "public"."items_proportions" from "anon";

revoke truncate on table "public"."items_proportions" from "anon";

revoke update on table "public"."items_proportions" from "anon";

revoke delete on table "public"."items_proportions" from "authenticated";

revoke insert on table "public"."items_proportions" from "authenticated";

revoke references on table "public"."items_proportions" from "authenticated";

revoke select on table "public"."items_proportions" from "authenticated";

revoke trigger on table "public"."items_proportions" from "authenticated";

revoke truncate on table "public"."items_proportions" from "authenticated";

revoke update on table "public"."items_proportions" from "authenticated";

revoke delete on table "public"."items_proportions" from "service_role";

revoke insert on table "public"."items_proportions" from "service_role";

revoke references on table "public"."items_proportions" from "service_role";

revoke select on table "public"."items_proportions" from "service_role";

revoke trigger on table "public"."items_proportions" from "service_role";

revoke truncate on table "public"."items_proportions" from "service_role";

revoke update on table "public"."items_proportions" from "service_role";

revoke delete on table "public"."members" from "anon";

revoke insert on table "public"."members" from "anon";

revoke references on table "public"."members" from "anon";

revoke select on table "public"."members" from "anon";

revoke trigger on table "public"."members" from "anon";

revoke truncate on table "public"."members" from "anon";

revoke update on table "public"."members" from "anon";

revoke delete on table "public"."members" from "authenticated";

revoke insert on table "public"."members" from "authenticated";

revoke references on table "public"."members" from "authenticated";

revoke select on table "public"."members" from "authenticated";

revoke trigger on table "public"."members" from "authenticated";

revoke truncate on table "public"."members" from "authenticated";

revoke update on table "public"."members" from "authenticated";

revoke delete on table "public"."members" from "service_role";

revoke insert on table "public"."members" from "service_role";

revoke references on table "public"."members" from "service_role";

revoke select on table "public"."members" from "service_role";

revoke trigger on table "public"."members" from "service_role";

revoke truncate on table "public"."members" from "service_role";

revoke update on table "public"."members" from "service_role";

revoke delete on table "public"."rooms" from "anon";

revoke insert on table "public"."rooms" from "anon";

revoke references on table "public"."rooms" from "anon";

revoke select on table "public"."rooms" from "anon";

revoke trigger on table "public"."rooms" from "anon";

revoke truncate on table "public"."rooms" from "anon";

revoke update on table "public"."rooms" from "anon";

revoke delete on table "public"."rooms" from "authenticated";

revoke insert on table "public"."rooms" from "authenticated";

revoke references on table "public"."rooms" from "authenticated";

revoke select on table "public"."rooms" from "authenticated";

revoke trigger on table "public"."rooms" from "authenticated";

revoke truncate on table "public"."rooms" from "authenticated";

revoke update on table "public"."rooms" from "authenticated";

revoke delete on table "public"."rooms" from "service_role";

revoke insert on table "public"."rooms" from "service_role";

revoke references on table "public"."rooms" from "service_role";

revoke select on table "public"."rooms" from "service_role";

revoke trigger on table "public"."rooms" from "service_role";

revoke truncate on table "public"."rooms" from "service_role";

revoke update on table "public"."rooms" from "service_role";

alter table "public"."items" drop constraint "Items_payer_id_fkey";

alter table "public"."items_proportions" drop constraint "items_proportions_item_id_fkey";

alter table "public"."items_proportions" drop constraint "items_proportions_member_id_fkey";

alter table "public"."members" drop constraint "members_room_fkey";

alter table "public"."members" drop constraint "members_user_id_fkey";

alter table "public"."items" drop constraint "Item_pkey";

alter table "public"."items_proportions" drop constraint "items_proportions_pkey";

alter table "public"."members" drop constraint "members_pkey";

alter table "public"."rooms" drop constraint "rooms_pkey";

drop index if exists "public"."Item_pkey";

drop index if exists "public"."items_proportions_pkey";

drop index if exists "public"."members_pkey";

drop index if exists "public"."rooms_pkey";

drop table "public"."items";

drop table "public"."items_proportions";

drop table "public"."members";

drop table "public"."rooms";


  create table "public"."ItemConsumptions" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "item_id" uuid,
    "member_id" uuid,
    "proportion" numeric,
    "room_id" uuid
      );


alter table "public"."ItemConsumptions" enable row level security;


  create table "public"."Items" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "name" text,
    "price" real,
    "payer_id" uuid,
    "room_id" uuid
      );


alter table "public"."Items" enable row level security;


  create table "public"."Members" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "name" text,
    "room_id" uuid,
    "user_id" uuid
      );


alter table "public"."Members" enable row level security;


  create table "public"."Rooms" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "name" text
      );


alter table "public"."Rooms" enable row level security;

CREATE UNIQUE INDEX "ItemConsumptions_pkey" ON public."ItemConsumptions" USING btree (id);

CREATE UNIQUE INDEX "Items_pkey" ON public."Items" USING btree (id);

CREATE UNIQUE INDEX "Members_pkey" ON public."Members" USING btree (id);

CREATE UNIQUE INDEX "Rooms_pkey" ON public."Rooms" USING btree (id);

alter table "public"."ItemConsumptions" add constraint "ItemConsumptions_pkey" PRIMARY KEY using index "ItemConsumptions_pkey";

alter table "public"."Items" add constraint "Items_pkey" PRIMARY KEY using index "Items_pkey";

alter table "public"."Members" add constraint "Members_pkey" PRIMARY KEY using index "Members_pkey";

alter table "public"."Rooms" add constraint "Rooms_pkey" PRIMARY KEY using index "Rooms_pkey";

alter table "public"."ItemConsumptions" add constraint "ItemConsumptions_item_id_fkey" FOREIGN KEY (item_id) REFERENCES public."Items"(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."ItemConsumptions" validate constraint "ItemConsumptions_item_id_fkey";

alter table "public"."ItemConsumptions" add constraint "ItemConsumptions_member_id_fkey" FOREIGN KEY (member_id) REFERENCES public."Members"(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."ItemConsumptions" validate constraint "ItemConsumptions_member_id_fkey";

alter table "public"."ItemConsumptions" add constraint "ItemConsumptions_room_id_fkey" FOREIGN KEY (room_id) REFERENCES public."Rooms"(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."ItemConsumptions" validate constraint "ItemConsumptions_room_id_fkey";

alter table "public"."Items" add constraint "Items_payer_id_fkey" FOREIGN KEY (payer_id) REFERENCES public."Members"(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."Items" validate constraint "Items_payer_id_fkey";

alter table "public"."Items" add constraint "Items_room_id_fkey" FOREIGN KEY (room_id) REFERENCES public."Rooms"(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."Items" validate constraint "Items_room_id_fkey";

alter table "public"."Members" add constraint "Members_room_id_fkey" FOREIGN KEY (room_id) REFERENCES public."Rooms"(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."Members" validate constraint "Members_room_id_fkey";

alter table "public"."Members" add constraint "Members_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."Members" validate constraint "Members_user_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public."itemConsumptions_room_id"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$BEGIN
  SELECT room_id INTO NEW.room_id FROM "Items"
  WHERE id = NEW.item_id;
  RETURN NEW;
END;$function$
;

CREATE OR REPLACE FUNCTION public.item_room_id()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$BEGIN
  SELECT room_id INTO NEW.room_id from "Members"
  WHERE id = NEW.payer_id;
  RETURN NEW;
END;$function$
;

grant delete on table "public"."ItemConsumptions" to "anon";

grant insert on table "public"."ItemConsumptions" to "anon";

grant references on table "public"."ItemConsumptions" to "anon";

grant select on table "public"."ItemConsumptions" to "anon";

grant trigger on table "public"."ItemConsumptions" to "anon";

grant truncate on table "public"."ItemConsumptions" to "anon";

grant update on table "public"."ItemConsumptions" to "anon";

grant delete on table "public"."ItemConsumptions" to "authenticated";

grant insert on table "public"."ItemConsumptions" to "authenticated";

grant references on table "public"."ItemConsumptions" to "authenticated";

grant select on table "public"."ItemConsumptions" to "authenticated";

grant trigger on table "public"."ItemConsumptions" to "authenticated";

grant truncate on table "public"."ItemConsumptions" to "authenticated";

grant update on table "public"."ItemConsumptions" to "authenticated";

grant delete on table "public"."ItemConsumptions" to "service_role";

grant insert on table "public"."ItemConsumptions" to "service_role";

grant references on table "public"."ItemConsumptions" to "service_role";

grant select on table "public"."ItemConsumptions" to "service_role";

grant trigger on table "public"."ItemConsumptions" to "service_role";

grant truncate on table "public"."ItemConsumptions" to "service_role";

grant update on table "public"."ItemConsumptions" to "service_role";

grant delete on table "public"."Items" to "anon";

grant insert on table "public"."Items" to "anon";

grant references on table "public"."Items" to "anon";

grant select on table "public"."Items" to "anon";

grant trigger on table "public"."Items" to "anon";

grant truncate on table "public"."Items" to "anon";

grant update on table "public"."Items" to "anon";

grant delete on table "public"."Items" to "authenticated";

grant insert on table "public"."Items" to "authenticated";

grant references on table "public"."Items" to "authenticated";

grant select on table "public"."Items" to "authenticated";

grant trigger on table "public"."Items" to "authenticated";

grant truncate on table "public"."Items" to "authenticated";

grant update on table "public"."Items" to "authenticated";

grant delete on table "public"."Items" to "service_role";

grant insert on table "public"."Items" to "service_role";

grant references on table "public"."Items" to "service_role";

grant select on table "public"."Items" to "service_role";

grant trigger on table "public"."Items" to "service_role";

grant truncate on table "public"."Items" to "service_role";

grant update on table "public"."Items" to "service_role";

grant delete on table "public"."Members" to "anon";

grant insert on table "public"."Members" to "anon";

grant references on table "public"."Members" to "anon";

grant select on table "public"."Members" to "anon";

grant trigger on table "public"."Members" to "anon";

grant truncate on table "public"."Members" to "anon";

grant update on table "public"."Members" to "anon";

grant delete on table "public"."Members" to "authenticated";

grant insert on table "public"."Members" to "authenticated";

grant references on table "public"."Members" to "authenticated";

grant select on table "public"."Members" to "authenticated";

grant trigger on table "public"."Members" to "authenticated";

grant truncate on table "public"."Members" to "authenticated";

grant update on table "public"."Members" to "authenticated";

grant delete on table "public"."Members" to "service_role";

grant insert on table "public"."Members" to "service_role";

grant references on table "public"."Members" to "service_role";

grant select on table "public"."Members" to "service_role";

grant trigger on table "public"."Members" to "service_role";

grant truncate on table "public"."Members" to "service_role";

grant update on table "public"."Members" to "service_role";

grant delete on table "public"."Rooms" to "anon";

grant insert on table "public"."Rooms" to "anon";

grant references on table "public"."Rooms" to "anon";

grant select on table "public"."Rooms" to "anon";

grant trigger on table "public"."Rooms" to "anon";

grant truncate on table "public"."Rooms" to "anon";

grant update on table "public"."Rooms" to "anon";

grant delete on table "public"."Rooms" to "authenticated";

grant insert on table "public"."Rooms" to "authenticated";

grant references on table "public"."Rooms" to "authenticated";

grant select on table "public"."Rooms" to "authenticated";

grant trigger on table "public"."Rooms" to "authenticated";

grant truncate on table "public"."Rooms" to "authenticated";

grant update on table "public"."Rooms" to "authenticated";

grant delete on table "public"."Rooms" to "service_role";

grant insert on table "public"."Rooms" to "service_role";

grant references on table "public"."Rooms" to "service_role";

grant select on table "public"."Rooms" to "service_role";

grant trigger on table "public"."Rooms" to "service_role";

grant truncate on table "public"."Rooms" to "service_role";

grant update on table "public"."Rooms" to "service_role";


  create policy "insert item consumption"
  on "public"."ItemConsumptions"
  as permissive
  for insert
  to public
with check (true);



  create policy "select item consumption"
  on "public"."ItemConsumptions"
  as permissive
  for select
  to public
using (true);



  create policy "update item consumption"
  on "public"."ItemConsumptions"
  as permissive
  for update
  to public
using (true)
with check ((proportion >= (0)::numeric));



  create policy "insert item"
  on "public"."Items"
  as permissive
  for insert
  to public
with check (true);



  create policy "select item"
  on "public"."Items"
  as permissive
  for select
  to public
using (true);



  create policy "insert member"
  on "public"."Members"
  as permissive
  for insert
  to public
with check (true);



  create policy "select member"
  on "public"."Members"
  as permissive
  for select
  to public
using (true);



  create policy "insert room"
  on "public"."Rooms"
  as permissive
  for insert
  to public
with check (true);



  create policy "select room"
  on "public"."Rooms"
  as permissive
  for select
  to public
using (true);


CREATE TRIGGER "itemConsumptions_room_id" BEFORE INSERT ON public."ItemConsumptions" FOR EACH ROW EXECUTE FUNCTION public."itemConsumptions_room_id"();

CREATE TRIGGER item_room_id BEFORE INSERT ON public."Items" FOR EACH ROW EXECUTE FUNCTION public.item_room_id();


