// types
import { MenuItemType } from "~/types/menuitem";

export default function HomeItemCard({
    title,
    description,
    link,
    openNewTab,
} : MenuItemType) {
    return (
        <a
            key={title}
            className="p-4 border rounded border-gray-300 hover:border-purple-500"
            href={link}
            target={openNewTab ? "_blank" : "_self"}
            rel="noopener, noreferrer"
        >
            <div className="flex flex-col gap-4">
                <div className="flex items-center justify-start gap-4">
                    <h2 className="text-xl font-semibold">
                        {title}
                    </h2>
                </div>
                <p className="text-md">
                    {description}
                </p>
            </div>
        </a>
    )
}