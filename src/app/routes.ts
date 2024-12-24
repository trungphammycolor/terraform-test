interface Domains {
    blog: string;
    githubCode: {
        javascript: string;
        typescript: string;
    }
}

export const domains: Domains = {
    blog: "https://nextjs.org/blog",
    githubCode: {
        javascript: "https://nextjs.org/blog",
        typescript: "https://nextjs.org/blog"
    }
}

interface Paths {
    main: string;
    signIn: string;
    dashboard: string;
}

export const paths: Paths = {
    main: "/",
    signIn: "/sign-in",
    dashboard: "/dashboard"
};