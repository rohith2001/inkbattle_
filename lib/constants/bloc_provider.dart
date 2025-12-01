import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkbattle_frontend/logic/login/login_cubit.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> blocProviders = [
  BlocProvider(create: (context) => LoginCubit()),
];
