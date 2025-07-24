# Implementation Plan: SingleChildScrollView Photo Loading Mechanism

## Problem Statement

In the current implementation, when the user scrolls to the bottom of the `SingleChildScrollView` in `list_page.dart`, a `PhotoFetched` event is dispatched without the `findState` parameter. This means that the `PhotoBloc` doesn't know which filter criteria to use for fetching the next batch of photos.

## Solution

Modify the `_onScroll` method in the `_ListPageState` class in `list_page.dart` to access the current `findState` from the `FindCubit` and pass it to the `PhotoFetched` event.

### Current Implementation

```dart
void _onScroll() {
  if (_isBottom) context.read<PhotoBloc>().add(PhotoFetched());
}
```

### Modified Implementation

```dart
void _onScroll() {
  if (_isBottom) {
    final findState = context.read<FindCubit>().state;
    context.read<PhotoBloc>().add(PhotoFetched(findState: findState));
  }
}
```

## Testing

After implementing the solution, test it by:

1. Running the application
2. Applying some filters using the FindForm
3. Scrolling to the bottom of the list
4. Verifying that the next batch of photos is loaded with the same filter criteria

## Expected Outcome

When the user scrolls to the bottom of the list, the next batch of photos should be loaded with the same filter criteria as the current batch.