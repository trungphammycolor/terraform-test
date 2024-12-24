"use client";

// react
import { useState } from "react";
// next auth
import { signIn } from "next-auth/react";
// components
import SignInInputField from "~/app/sign-in/components/SignInInputField";
// routes
import { paths } from "~/app/routes";

interface FormSchema {
    email: string;
    password: string;
}

export default function SignInForm() {
    const [formSchema, setFormSchema] = useState<FormSchema>({
        email: "",
        password: ""
    });

    const handleFormSchema = (event: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value } = event.target;
        const newFormValue = { ...formSchema, [name]: value };

        setFormSchema(newFormValue);
    };

    const handleSubmit = async(event: React.FormEvent<HTMLFormElement>, data: FormSchema) => {
        event.preventDefault();
        
        if (data.email === "" || data.password === "") {
            return;
        }

        console.log("data", data);
        

        const response = await signIn("credentials", {
            email: data.email,
            password: data.password,
            redirect: true,
            callbackUrl: paths.dashboard
        });

        console.log("response", response);
        

        /*
            * sign in success response
            {
                "error": null,
                "status": 200,
                "ok": true,
                "url": "http://localhost:3000/sign-in/"
            }
            
            * sign in error response
            url : https://github.com/aws/aws-sdk-js-v3/tree/main/clients/client-cognito-identity-provider
            {
                "error": "error type",
                "status": error status code,
                "ok": false,
                "url": null
            }
        */
        console.log("response", response)
    };

    return (
        <div className="flex flex-col gap-4">
            <form
                className="flex flex-col gap-4"
                onSubmit={(e) => handleSubmit(e, formSchema)}
            >
                <SignInInputField
                    label="Username"
                    type="text"
                    name="text"
                    value={formSchema.email}
                    onChange={handleFormSchema}
                    placeholder="your username"
                />

                <SignInInputField
                    label="Password"
                    type="password"
                    name="password"
                    value={formSchema.password}
                    onChange={handleFormSchema}
                    placeholder="••••••••"
                />

                <button
                    className="w-full  bg-primary-600 hover:bg-primary-700 font-medium rounded-lg text-base py-3 text-center mt-2"
                    type="submit"
                >
                    Sign in
                </button>
            </form>

            {/* <div className="flex items-center justify-center my-4">
                <div className="flex-grow border-t border-gray-200" />
                <p className="mx-3 text-base font-medium text-gray-500">OR</p>
                <div className="flex-grow border-t border-gray-200" />
            </div> */}

        </div>
    )
}