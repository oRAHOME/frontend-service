defmodule FrontendServiceWeb.GoogleSignInButtonComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div>
    <button id="google-login-btn" class="w-full flex items-center justify-center gap-2 px-4 py-3 text-gray-600 bg-white border border-gray-300 rounded-lg shadow-sm hover:bg-gray-50">
      <img src="/images/google-icon.png" alt="Google" class="h-5 w-5">
      Sign in with Google
    </button>

    <script>
      document.getElementById("google-login-btn").addEventListener("click", function () {
        const popup = window.open(
          "http://localhost:8000/auth/google", // Opens Google OAuth in a popup
          "Google Login",
          "width=500,height=600"
        );

        window.addEventListener("message", function (event) {
          if (event.origin !== "http://localhost:8000") return; // Ensure it's from the right server
          if (event.data.accessToken) {
            localStorage.setItem("accessToken", event.data.accessToken); // Save JWT token
            window.location.href = "/dashboard"; // Redirect to dashboard after login
          }
        }, false);
      });
    </script>
    </div>
    """
  end
end
