// components
import SignInHero from "~/sign-in/components/SignInHero";
import SignInForm from "~/sign-in/components/SignInForm";
import SignInFooter from "~/sign-in/components/SignInFooter";

export default function SignInPage() {
  return (
    <section className="container mx-auto h-screen flex flex-col justify-center items-center gap-2">
      <div className="w-full max-w-sm flex flex-col rounded-xl shadow-xl gap-8 mt-8 mb-4 p-8">
        <SignInHero />
        <SignInForm />
      </div>

      <SignInFooter />
    </section>
  );
}
