# UIKit Guidelines

## UIKit Structure

The UIKit is located in `lib/uikit/` and contains 31 component categories:
- `colors/` — Color scheme (30+ named colors)
- `text/` — Text styles (GolosText font family, sizes 10-32)
- `sizes/` — Semantic spacing and sizing constants
- `themes/` — App theme data (light/dark)
- `buttons/` — Button variants (primary, transparent, black, icon)
- `fields/` — Text fields with validators and formatters
- `scaffold/` — AppScaffold wrapper
- `menu/` — Bottom navigation, side menu
- `event_card/` — Event card widgets
- `table/` — Table widgets with loading/error states
- `alerts/` — Dialogs and alerts
- `bottom_sheet/` — Bottom sheet components
- `pickers/` — Picker components
- `images/` — Image wrappers
- `progress/` — Progress indicators
- `status_event/` — Event status widgets
- `carousel/` — Carousel widgets
- `search/` — Search components
- `contact/` — Contact info widgets
- `info/` — Info display widgets
- `others/` — Shimmer, inactive wrapper, transitions
- `layout_helpers/` — Section widgets, layout utilities
- `transitions/` — Animation transitions
- `app_tab_bar_view/` — Tab bar view
- `selector_widget/` — Selector components
- `expandable_selector_widget/` — Expandable selectors
- `app_label_picker/` — Label picker
- `info_item_with_action/` — Info items with action buttons
- `meeting_variant/` — Meeting variant display
- `search_bar_button/` — Search bar button

## Theming System

### Color Scheme

Access colors via `context.appColorScheme`:
```dart
final colors = context.appColorScheme;
Container(color: colors.white);
Container(color: colors.error900);
Container(color: colors.warning900);
Container(color: colors.green900);
Container(color: colors.gray500);
```

Available colors: `white`, `black900`, `red900`, `gray900`, `gray700`, `gray500`, `gray400`, `gray300`, `gray200`, `green900`, `green500`, `warning900`, `error900`, and others.

### Text Scheme

Access text styles via `context.appTextScheme`:
```dart
final text = context.appTextScheme;
Text('Hello', style: text.t32Bold);
Text('World', style: text.t16);
Text('Small', style: text.t12);
```

Available styles: `t32Bold`, `tSemibold32`, `t32`, `t24Bold`, `t24`, `t20Bold`, `t20`, `t16Bold`, `t16`, `t14Bold`, `t14Medium`, `t14`, `t12Bold`, `t12`, `t10`, all using GolosText font family.

### Sizes Scheme

Access semantic sizes via `context.appSizesScheme`:
```dart
final sizes = context.appSizesScheme;
Padding(
  padding: EdgeInsets.all(sizes.paddingGeneral),  // 16
  child: child,
);
```

Available sizes:
- Padding: `paddingMicroscopic`(1), `paddingTiny`(2), `paddingSmall`(4), `paddingMedium`(8), `paddingStandard`(12), `paddingGeneral`(16), `paddingLarge`(20), `paddingExtraLarge`(24)
- Border radius: `borderRadiusSmall`(4), `borderRadiusMedium`(8), `borderRadiusGeneral`(16), `borderRadiusHuge`(20)
- Icons: `iconSizeStandart`(12), `iconSizeGeneral`(16), `iconSizeLarge`(20), `iconSizeHuge`(24)
- Layout: `mobileWidth`(768), `sidebarGeneral`(400), `dialogSizeMinimum`(400)

### Theme Access Extension

Use convenience extensions on `BuildContext`:
```dart
context.appColorScheme    // AppColorScheme
context.appTextScheme     // AppTextScheme
context.appSizesScheme    // AppSizesScheme
context.appButtonScheme   // AppButtonScheme
```

## Button Components

### AppPrimaryButton

```dart
AppPrimaryButton(
  child: Text('Submit'),
  onPressed: () {},
  size: AppButtonSize.large,  // large, medium, small
  state: ButtonState.active,  // active, disabled, loading
);
```

Button variants are theme-driven via `AppButtonScheme`:
- `primaryLarge`, `primaryMedium`, `primarySmall`
- `transparentLarge`, `transparentMedium`, `transparentSmall`
- `blackLarge`, `blackMedium`, `blackSmall`
- Icon variants

## Field Components

### AppTextField

```dart
AppTextField(
  controller: _controller,
  focusNode: _focusNode,
  validator: NameValidator(),
  clearButton: true,
  obscureText: false,
  maxLines: 1,
);
```

- Supports validators from `lib/uikit/fields/validators/`
- Supports formatters from `lib/util/formatters/`
- Has mobile/desktop variants in `fields/widgets/mobile/` and `fields/widgets/desktop/`

Common validators: `email_validator.dart`, `name_validator.dart`, `date_validator.dart`, `field_validator.dart`

## Layout Helpers

### AppScaffold

```dart
AppScaffold(
  appBar: AppBar(title: Text('Title')),
  body: child,
  bottomNavigationBar: bottomBar,
);
```

### SectionWidget

```dart
SectionWidget(
  title: 'Section Title',
  iconPath: 'assets/icons/icon.svg',
  warning: 'Warning message',
  disabled: false,
  child: content,
);
```

## Adaptive UI (Mobile vs Desktop)

### Platform Detection

Use `context.isDesktop` extension on `BuildContext`:
```dart
if (context.isDesktop) {
  // Desktop layout
} else {
  // Mobile layout
}
```

Threshold: `AppSizes.kMobileWidth` (768.0)

### Screen Structure

Each screen SHOULD implement both mobile and desktop layouts:
```dart
class ExampleScreen extends ElementaryWidget<IExampleWM, ExampleScreenModel> {
  @override
  Widget buildMobile(BuildContext context, IExampleWM wm) {
    return buildMainContent(wm, isDesktop: false);
  }

  @override
  Widget buildDesktop(BuildContext context, IExampleWM wm) {
    return buildMainContent(wm, isDesktop: true);
  }
}
```

### File Organization

Place platform-specific widgets in separate directories:
```
lib/features/<feature>/presentation/screens/<screen>/
  mobile/
    screen_mobile_widget.dart
  desktop/
    screen_desktop_widget.dart
```

## Widget Composition Patterns

### Composite Widgets

Complex widgets are composed of smaller sub-widgets within the same directory:
```dart
class EventCardWidget extends StatelessWidget {
  // Uses all three schemes
  final colors = context.appColorScheme;
  final text = context.appTextScheme;
  final sizes = context.appSizesScheme;
  
  // Composed of sub-widgets
  EventStatusWidget(status);
  EventCardUserAvatar(user);
  EventCardDateTimeWidget(dateTime);
}
```

### Shimmer Loading States

Use shimmer widgets for loading states:
```dart
Shimmer(
  loading: isLoading,
  child: contentWidget,
);
```

Available shimmer widgets:
- `Shimmer` — Generic shimmer wrapper
- `BaseShimmerWidget` — 3-column shimmer with gradient
- `CardShimmerWidget` — Configurable card shimmer
- `CardsListShimmerWidget` — List of card shimmers
- Feature-specific shimmers (e.g., `my_partners_list_shimmer_widget.dart`)

## UI Best Practices

- You SHOULD use theme extensions (`appColorScheme`, `appTextScheme`, `appSizesScheme`) instead of hardcoded values
- You SHOULD implement both `buildMobile` and `buildDesktop` for all screens
- You SHOULD compose complex widgets from smaller reusable sub-widgets
- You SHOULD use `Shimmer` for loading states
- You SHOULD use semantic size names (`paddingGeneral`) instead of raw numbers
- You SHOULD use GolosText font family for all text
- You SHOULD place platform-specific widgets in `mobile/` and `desktop/` subdirectories
- You SHOULD use `AppTextField` with validators for all form inputs
- You SHOULD use `AppPrimaryButton` with appropriate size/state for buttons
