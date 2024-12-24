// components
import HomeHero from "~/components/HomeHero";
import HomeItemCard from "~/components/HomeItemCard";
import HomeFooter from "~/components/HomeFooter";
// libs
import { MENU_ITEM_LIST } from "~/libs/config";
// types
import { MenuItemType } from "~/types/menuitem";

export default function Home() {
  return (
    <main>
      <div className="container mx-auto h-screen flex flex-col justify-center items-center">
        <HomeHero />
        <div className="w-full max-w-3xl grid grid-cols-1 md:grid-cols-2 gap-4 my-8 px-2">
          {MENU_ITEM_LIST.map((item: MenuItemType, idx: number) => (
            <HomeItemCard
              key={`home-item-card-${idx}`}
              title={item.title}
              description={item.description}
              link={item.link}
              openNewTab={item.openNewTab}
            />
          ))}
        </div>
        <HomeFooter />
      </div>
    </main>
  );
}
