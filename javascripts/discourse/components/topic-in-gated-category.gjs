import Component from "@glimmer/component";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import routeAction from "discourse/helpers/route-action";
import { i18n } from "discourse-i18n";

export default class TopicInGatedCategory extends Component {
  @service currentUser;

  get enabledCategories() {
    return settings.enabled_categories
      .split("|")
      .map((id) => parseInt(id, 10))
      .filter((id) => !isNaN(id));
  }

  get enabledTags() {
    return settings.enabled_tags.split("|").filter(Boolean);
  }

  get enabledGroups() {
    return settings.enabled_groups
      .split("|")
      .map((id) => parseInt(id, 10))
      .filter((id) => !isNaN(id));
  }

  get userAllowedByGroup() {
    return this.currentUser?.groups?.some((g) =>
      this.enabledGroups.includes(g.id)
    );
  }

  get topicCategoryId() {
    return this.args.categoryId ?? null;
  }

  get topicTags() {
    return this.args.tags ?? [];
  }

  get pageType() {
    return this.args.pageType;
  }

  // get shouldShow() {
  //   if (this.userAllowedByGroup) {
  //     return false;
  //   }

  //   const isDirectoryPage = this.pageType === "directory";
  //   const isProfilePage = this.pageType === "profile";
  //   const isOwnProfile =
  //     this.pageType === "profile" &&
  //     this.args.profileUser &&
  //     this.args.profileUser.id === this.currentUser?.id;

  //   if (isDirectoryPage) {
  //     return true;
  //   }

  //   if (isProfilePage) {
  //     if (isOwnProfile) {
  //       return false;
  //     }

  //     return true;
  //   }
  //   const hasGroupGating = this.enabledGroups.length > 0;
  //   const gatedByCategory = this.enabledCategories.includes(
  //     this.topicCategoryId
  //   );
  //   const gatedByTag = this.topicTags.some((tag) =>
  //     this.enabledTags.includes(typeof tag === "string" ? tag : tag.name)
  //   );

  //   const hasAnyCategoryOrTag =
  //     this.enabledCategories.length > 0 || this.enabledTags.length > 0;

  //   if (!hasAnyCategoryOrTag && !hasGroupGating) {
  //     return false;
  //   }

  //   if (hasAnyCategoryOrTag && !gatedByCategory && !gatedByTag) {
  //     return false;
  //   }

  //   if (!hasGroupGating && this.currentUser) {
  //     return false;
  //   }

  //   return true;
  // }

  get shouldShow() {
    const isLoggedIn = !!this.currentUser;
    const isAllowedUser = this.userAllowedByGroup;

    const isDirectoryPage = this.pageType === "directory";
    const isProfilePage = this.pageType === "profile";

    const isOwnProfile =
      isProfilePage &&
      isLoggedIn &&
      this.args.profileUser &&
      this.args.profileUser.id === this.currentUser.id;

    if (isAllowedUser) {
      return false;
    }

    if (isDirectoryPage) {
      return true;
    }

    if (isProfilePage) {
      if (isOwnProfile) {
        return false;
      }

      return true;
    }

    const gatedByCategory = this.enabledCategories.includes(
      this.topicCategoryId
    );

    const gatedByTag = (this.topicTags || []).some((tag) =>
      this.enabledTags.includes(typeof tag === "string" ? tag : tag.name)
    );

    const isGatedContent = gatedByCategory || gatedByTag;

    if (!isLoggedIn) {
      return isGatedContent;
    }

    if (isLoggedIn && !isAllowedUser) {
      return isGatedContent;
    }

    return false;
  }

  @action
  addBodyClass() {
    document.body.classList.add("topic-in-gated-category");
  }

  @action
  removeBodyClass() {
    document.body.classList.remove("topic-in-gated-category");
  }

  <template>
    {{#if this.shouldShow}}
      <div
        class="custom-gated-topic-container"
        {{didInsert this.addBodyClass}}
        {{willDestroy this.removeBodyClass}}
      >
        <div class="custom-gated-topic-content">
          <div class="custom-gated-topic-content--header">
            {{i18n (themePrefix "heading_text")}}
          </div>

          <p class="custom-gated-topic-content--text">
            {{i18n (themePrefix "subheading_text")}}
          </p>

          <div class="custom-gated-topic-content--cta">
            <div class="custom-gated-topic-content--cta__signup">
              <DButton
                @action={{routeAction "showCreateAccount"}}
                class="btn-primary btn-large sign-up-button"
                @translatedLabel={{i18n (themePrefix "signup_cta_label")}}
              />
            </div>

            <div class="custom-gated-topic-content--cta__login">
              <DButton
                @action={{routeAction "showLogin"}}
                @id="cta-login-link"
                class="btn btn-text login-button"
                @translatedLabel={{i18n (themePrefix "login_cta_label")}}
              />
            </div>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
