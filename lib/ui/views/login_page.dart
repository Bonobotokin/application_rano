import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_event.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/home/home_bloc.dart';
import 'package:application_rano/blocs/home/home_event.dart';
import 'package:application_rano/ui/routing/routes.dart';
import 'package:get/get.dart';
import 'package:application_rano/blocs/auth/auth_event.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    final HomeBloc homeBloc = BlocProvider.of<HomeBloc>(context);

    return Scaffold(
      backgroundColor: Colors.green,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            homeBloc.add(
                LoadHomePageData(accessToken: state.userInfo.lastToken ?? ''));
            navigateToHome(context);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return _buildLoadingState(context);
            } else if (state is AuthFailure) {
              return _buildLoginForm(context, authBloc,
                  errorMessage: state.error);
            } else {
              return _buildLoginForm(context, authBloc);
            }
          },
        ),
      ),
    );
  }

  void navigateToHome(BuildContext context) {
    Get.offNamed(AppRoutes.home);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLoginForm(BuildContext context, AuthBloc authBloc,
      {String? errorMessage}) {
    return Center(
      child: Container(
        width: 300,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
                height: 80.0,
                child: Image.asset(
                  'assets/images/img.png',
                  width: 200,
                  height: 200,
                )),
            SizedBox(height: 20.0),
            TextFormField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                hintText: 'Numéro de téléphone',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(15),
                prefixIcon: Icon(Icons.phone, color: Colors.grey),
              ),
              style: TextStyle(color: Colors.black),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez saisir un numéro de téléphone';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Mot de passe',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(15),
                prefixIcon: Icon(Icons.lock, color: Colors.grey),
              ),
              style: TextStyle(color: Colors.black),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez saisir un mot de passe';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton.icon(
                onPressed: () async {
                  authBloc.add(LoginRequested(
                    phoneNumber: phoneNumberController.text,
                    password: passwordController.text,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                icon: Icon(Icons.login, color: Colors.white),
                label: Text(
                  'Se connecter',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            if (errorMessage != null) SizedBox(height: 20.0),
            Text(
              errorMessage ?? '',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
