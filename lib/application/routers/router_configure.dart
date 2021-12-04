import 'package:shelf_router/shelf_router.dart';

import './i_router.dart';

class RouterConfigure {
  final Router _router;
  final List<IRouter> _routers = <IRouter>[
    // UserRouter(),
    // CategoriesRouter(),
    // SupplierRouter(),
    // ScheduleRouter(),
    // ChatRouter()
  ];

  RouterConfigure(this._router);

  void configure() => _routers.forEach((IRouter r) => r.configure(_router));
}