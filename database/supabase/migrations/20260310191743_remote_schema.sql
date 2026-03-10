drop policy "insert item" on "public"."Items";

drop policy "select item" on "public"."Items";

drop policy "insert member" on "public"."Members";

drop policy "select member" on "public"."Members";


  create policy "all commands on item"
  on "public"."Items"
  as permissive
  for all
  to public
using (true);



  create policy "all commands on member"
  on "public"."Members"
  as permissive
  for all
  to public
using (true);



