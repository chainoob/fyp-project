import 'package:go_router/go_router.dart';
import 'package:smartmeter/controllers/provider.dart';
import 'package:smartmeter/screens/login_screen.dart';
import 'package:smartmeter/screens/register_screen.dart';
import 'package:smartmeter/screens/students/student_shell.dart';
import 'package:smartmeter/screens/staffs/staff_shell.dart';

class AppRoutes {
  static const login = '/';
  static const register = '/register';
  static const studentHome = '/student';
  static const staffHome = '/staff';

}

class AppRouter {
  static GoRouter create(AuthProvider auth) {
    return GoRouter(
      initialLocation: AppRoutes.login,
      refreshListenable: auth,
      routes: [
        GoRoute(
          path: AppRoutes.login, 
          builder: (context, state) => const LoginScreen()
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterScreen()
        ),
        GoRoute(
          path: AppRoutes.studentHome, 
          builder: (context, state) => const StudentShell()
        ),
        GoRoute(
          path: AppRoutes.staffHome, 
          builder: (context, state) => const StaffShell()
        ),
      ],
      redirect: (context, state) {
        final loggedIn = auth.loggedIn;
        final isLoginRoute = state.uri.toString() == AppRoutes.login;

        if (!loggedIn && !isLoginRoute) return AppRoutes.login;
        if (loggedIn && isLoginRoute) {
          return auth.isStaff ? AppRoutes.staffHome : AppRoutes.studentHome;
        }
        return null;
      },
    );
  }
}