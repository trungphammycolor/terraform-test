// routes
import { paths } from "~/app/routes";
// types
import { MenuItemType } from "~/types/menuitem";

export const MENU_ITEM_LIST: MenuItemType[] = [
  {
    title: "Sign in",
    description:
      "provide a sign in page implemented using NextAuth with AWS Cognito.",
    link: paths.signIn,
    openNewTab: false,
  },

];
