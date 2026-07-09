export enum ButtonFeedbackState {
  NORMAL = 0,
  HOVERED = 1,
  PRESSED = 2
}

export const BUTTON_NORMAL_SCALE: number = 1;
export const BUTTON_HOVER_SCALE: number = 1.03;
export const BUTTON_PRESSED_SCALE: number = 0.96;

export function getButtonFeedbackScale(feedbackState: ButtonFeedbackState): number {
  if (feedbackState === ButtonFeedbackState.PRESSED) {
    return BUTTON_PRESSED_SCALE;
  }
  if (feedbackState === ButtonFeedbackState.HOVERED) {
    return BUTTON_HOVER_SCALE;
  }
  return BUTTON_NORMAL_SCALE;
}
