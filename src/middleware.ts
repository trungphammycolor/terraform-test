// next
import { NextRequest, NextResponse } from "next/server";
// nextauth
import { getToken } from "next-auth/jwt";
// routes
import { paths } from "~/app/routes";

export const config = {
  matcher: [
    "/((?!api|_next/static|_next/image|assets|favicon.ico|.*.png|.*\\..*|_next).*)",
  ],
};

export const middleware = async (req: NextRequest) => {
  const pathname = req.nextUrl.pathname;

  let response = NextResponse.next();

  const session = await getToken({ req, secret: process.env.NEXTAUTH_SECRET });
  const isAuthenticated = session?.accessToken;

  if (isAuthenticated) {
    if (!pathname.startsWith(paths.dashboard)) {
      response = NextResponse.redirect(new URL(paths.dashboard, req.url));
    }
  } else {
    if (pathname.startsWith(paths.dashboard)) {
      response = NextResponse.redirect(new URL(paths.signIn, req.url));
    }
  }

  return response;
};
